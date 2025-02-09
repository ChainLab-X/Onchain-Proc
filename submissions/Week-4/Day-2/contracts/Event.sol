// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract EventContract {

    enum EventType {
            free,
            paid
        }

    event EventCreated (uint256 _id, address _organizer);

    struct EventDetails {
        string _title;
        string _description;
        uint256 _startDate;
        uint256 _endDate;
        EventType _type;
        uint32 _expectedGuestCount;
        uint32 _registeredGuestCount;
        uint256 _verifiedGuestCount;
        address _organizer; // Added organizer field
    }

    //state variables
    uint256 public event_count;
    mapping(uint256 => EventDetails) public events;

    // write functions 
    // create event 

    function createEvent(
        string memory _title, 
        string memory _desc, 
        uint256 _startDate, 
        uint256 _endDate, 
        EventType _type, 
        uint32 _expectedGuestCount, 
        uint32 _registeredGuestCount, 
        uint256 _verifiedGuestCount // Changed type to uint256
    ) external {
        uint256 _eventId = event_count;

        require(msg.sender != address(0), "UNAUTHORIZED ACCESS");
        require(_startDate > block.timestamp, "START DATE MUST BE IN THE FUTURE");
        require(_startDate < _endDate, "END DATE MUST BE AFTER START DATE");

        EventDetails memory _updatedEvent = EventDetails({
            _title: _title,
            _description: _desc,
            _startDate: _startDate,
            _endDate: _endDate,
            _type: _type,
            _expectedGuestCount: _expectedGuestCount,
            _registeredGuestCount: _registeredGuestCount,
            _verifiedGuestCount: _verifiedGuestCount,
            _organizer: msg.sender
        });

        events[_eventId] = _updatedEvent;

        event_count++; // Increment event_count after assigning the event

        emit EventCreated(_eventId, msg.sender);
    }
    // register for event 
    // validation/confirmation of ticket 

    // read functions 
}