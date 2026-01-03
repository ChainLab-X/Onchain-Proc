// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ParkingMarket
 * @dev Decentralized marketplace for parking space listings with real-time availability
 * @notice Parking owners can list spaces, drivers can reserve and pay in crypto/stablecoins
 */
contract ParkingMarket is Ownable, ReentrancyGuard {
    
    // Structs
    struct ParkingSpace {
        uint256 id;
        address owner;
        string location;
        string description;
        uint256 pricePerHour; // in wei or stablecoin smallest unit
        bool isAvailable;
        uint256 totalSlots;
        uint256 availableSlots;
        uint256 createdAt;
    }

    struct Reservation {
        uint256 id;
        uint256 spaceId;
        address driver;
        uint256 startTime;
        uint256 endTime;
        uint256 totalCost;
        bool isActive;
        bool isCompleted;
    }

    // State variables
    uint256 private _spaceIdCounter;
    uint256 private _reservationIdCounter;
    uint256 public platformFeePercentage = 5; // 5% platform fee
    address public feeCollector;

    mapping(uint256 => ParkingSpace) public parkingSpaces;
    mapping(uint256 => Reservation) public reservations;
    mapping(address => uint256[]) public ownerSpaces;
    mapping(address => uint256[]) public driverReservations;

    // Events
    event SpaceListed(
        uint256 indexed spaceId,
        address indexed owner,
        string location,
        uint256 pricePerHour,
        uint256 totalSlots
    );
    
    event SpaceUpdated(
        uint256 indexed spaceId,
        uint256 pricePerHour,
        bool isAvailable
    );
    
    event ReservationCreated(
        uint256 indexed reservationId,
        uint256 indexed spaceId,
        address indexed driver,
        uint256 startTime,
        uint256 endTime,
        uint256 totalCost
    );
    
    event ReservationCompleted(
        uint256 indexed reservationId,
        uint256 indexed spaceId
    );
    
    event ReservationCancelled(
        uint256 indexed reservationId,
        uint256 indexed spaceId
    );

    // Modifiers
    modifier onlySpaceOwner(uint256 spaceId) {
        require(parkingSpaces[spaceId].owner == msg.sender, "Not space owner");
        _;
    }

    modifier spaceExists(uint256 spaceId) {
        require(parkingSpaces[spaceId].id != 0, "Space does not exist");
        _;
    }

    constructor(address _feeCollector) Ownable(msg.sender) {
        require(_feeCollector != address(0), "Invalid fee collector");
        feeCollector = _feeCollector;
    }

    /**
     * @notice List a new parking space
     * @param location Location description of the parking space
     * @param description Additional details about the space
     * @param pricePerHour Price per hour in wei
     * @param totalSlots Total number of parking slots available
     */
    function listSpace(
        string memory location,
        string memory description,
        uint256 pricePerHour,
        uint256 totalSlots
    ) external returns (uint256) {
        require(bytes(location).length > 0, "Location required");
        require(pricePerHour > 0, "Price must be greater than 0");
        require(totalSlots > 0, "Must have at least 1 slot");

        _spaceIdCounter++;
        uint256 newSpaceId = _spaceIdCounter;

        parkingSpaces[newSpaceId] = ParkingSpace({
            id: newSpaceId,
            owner: msg.sender,
            location: location,
            description: description,
            pricePerHour: pricePerHour,
            isAvailable: true,
            totalSlots: totalSlots,
            availableSlots: totalSlots,
            createdAt: block.timestamp
        });

        ownerSpaces[msg.sender].push(newSpaceId);

        emit SpaceListed(newSpaceId, msg.sender, location, pricePerHour, totalSlots);
        return newSpaceId;
    }

    /**
     * @notice Update parking space details
     * @param spaceId ID of the parking space
     * @param pricePerHour New price per hour
     * @param isAvailable Availability status
     */
    function updateSpace(
        uint256 spaceId,
        uint256 pricePerHour,
        bool isAvailable
    ) external spaceExists(spaceId) onlySpaceOwner(spaceId) {
        require(pricePerHour > 0, "Price must be greater than 0");

        ParkingSpace storage space = parkingSpaces[spaceId];
        space.pricePerHour = pricePerHour;
        space.isAvailable = isAvailable;

        emit SpaceUpdated(spaceId, pricePerHour, isAvailable);
    }

    /**
     * @notice Reserve a parking space
     * @param spaceId ID of the parking space to reserve
     * @param startTime Start time of reservation (Unix timestamp)
     * @param durationHours Duration in hours
     */
    function reserveSpace(
        uint256 spaceId,
        uint256 startTime,
        uint256 durationHours
    ) external payable nonReentrant spaceExists(spaceId) returns (uint256) {
        ParkingSpace storage space = parkingSpaces[spaceId];
        
        require(space.isAvailable, "Space not available");
        require(space.availableSlots > 0, "No slots available");
        require(startTime >= block.timestamp, "Invalid start time");
        require(durationHours > 0, "Duration must be at least 1 hour");

        uint256 totalCost = space.pricePerHour * durationHours;
        require(msg.value >= totalCost, "Insufficient payment");

        // Calculate platform fee
        uint256 platformFee = (totalCost * platformFeePercentage) / 100;
        uint256 ownerPayment = totalCost - platformFee;

        // Create reservation
        _reservationIdCounter++;
        uint256 newReservationId = _reservationIdCounter;
        uint256 endTime = startTime + (durationHours * 1 hours);

        reservations[newReservationId] = Reservation({
            id: newReservationId,
            spaceId: spaceId,
            driver: msg.sender,
            startTime: startTime,
            endTime: endTime,
            totalCost: totalCost,
            isActive: true,
            isCompleted: false
        });

        // Update available slots
        space.availableSlots--;
        driverReservations[msg.sender].push(newReservationId);

        // Transfer payments
        payable(space.owner).transfer(ownerPayment);
        payable(feeCollector).transfer(platformFee);

        // Refund excess payment
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit ReservationCreated(
            newReservationId,
            spaceId,
            msg.sender,
            startTime,
            endTime,
            totalCost
        );

        return newReservationId;
    }

    /**
     * @notice Complete a reservation (called by driver or space owner)
     * @param reservationId ID of the reservation
     */
    function completeReservation(uint256 reservationId) external {
        Reservation storage reservation = reservations[reservationId];
        require(reservation.id != 0, "Reservation does not exist");
        require(reservation.isActive, "Reservation not active");
        require(
            msg.sender == reservation.driver || 
            msg.sender == parkingSpaces[reservation.spaceId].owner,
            "Not authorized"
        );

        reservation.isActive = false;
        reservation.isCompleted = true;

        // Free up the slot
        parkingSpaces[reservation.spaceId].availableSlots++;

        emit ReservationCompleted(reservationId, reservation.spaceId);
    }

    /**
     * @notice Get all parking spaces
     * @return Array of all space IDs
     */
    function getAllSpaces() external view returns (uint256[] memory) {
        uint256[] memory spaceIds = new uint256[](_spaceIdCounter);
        for (uint256 i = 1; i <= _spaceIdCounter; i++) {
            spaceIds[i - 1] = i;
        }
        return spaceIds;
    }

    /**
     * @notice Get available parking spaces
     * @return Array of available space IDs
     */
    function getAvailableSpaces() external view returns (uint256[] memory) {
        uint256 availableCount = 0;
        
        // Count available spaces
        for (uint256 i = 1; i <= _spaceIdCounter; i++) {
            if (parkingSpaces[i].isAvailable && parkingSpaces[i].availableSlots > 0) {
                availableCount++;
            }
        }

        // Create array of available space IDs
        uint256[] memory availableSpaceIds = new uint256[](availableCount);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= _spaceIdCounter; i++) {
            if (parkingSpaces[i].isAvailable && parkingSpaces[i].availableSlots > 0) {
                availableSpaceIds[index] = i;
                index++;
            }
        }

        return availableSpaceIds;
    }

    /**
     * @notice Get spaces owned by an address
     * @param owner Address of the owner
     * @return Array of space IDs
     */
    function getOwnerSpaces(address owner) external view returns (uint256[] memory) {
        return ownerSpaces[owner];
    }

    /**
     * @notice Get reservations made by a driver
     * @param driver Address of the driver
     * @return Array of reservation IDs
     */
    function getDriverReservations(address driver) external view returns (uint256[] memory) {
        return driverReservations[driver];
    }

    /**
     * @notice Update platform fee percentage (only owner)
     * @param newFeePercentage New fee percentage (0-100)
     */
    function updatePlatformFee(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 20, "Fee too high (max 20%)");
        platformFeePercentage = newFeePercentage;
    }

    /**
     * @notice Update fee collector address (only owner)
     * @param newFeeCollector New fee collector address
     */
    function updateFeeCollector(address newFeeCollector) external onlyOwner {
        require(newFeeCollector != address(0), "Invalid address");
        feeCollector = newFeeCollector;
    }
}
