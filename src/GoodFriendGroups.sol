// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GoodFriendGroups {
    struct Group {
        uint id;
        string name;
        address owner;
        mapping(address => bool) members;
        mapping(uint => Message) messages;
    }

    struct Message {
        uint id;
        address sender;
        string content;
    }

    mapping(uint => Group) groups;

    uint private groupCounter;
    uint private messageCounter;

    function createGroup(string memory _name) public returns(uint) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        uint groupId = groupCounter;
        groups[groupId].id = groupId;
        groups[groupId].name = _name;
        groups[groupId].owner = msg.sender;
        groupCounter++;
        return groupId;
    }

    function getGroupName(uint groupId) public view returns(string memory) {
        return(groups[groupId].name);
    }

    function deleteGroup(uint groupId) public {
        delete groups[groupId]; //Can I reuse the same id for another group?
    }

    function addMember(uint groupId, address member) public {
        require(!isMember(groupId, member), "Member is already in the group");
        groups[groupId].members[member] = true;
    }

    function removeMember(uint groupId, address member) public {
        require(isMember(groupId, member), "Member doesn't exist");
        groups[groupId].members[member] = false;
    }

    function getOwner(uint groupId) public view returns(address) {
        return(groups[groupId].owner);
    }

    function isMember(uint groupId, address member) public view returns(bool) {
        return groups[groupId].members[member];
    }

    function writeMessage(uint groupId, address member, string memory _content) public returns(uint) {
        require(isMember(groupId, member), "Only members can send messages");
        require(bytes(_content).length > 0, "Message cannot be empty");
        uint messageId = messageCounter;
        groups[groupId].messages[messageId] = Message({
            id: messageId,
            sender: msg.sender,
            content: _content
        });
        
        messageCounter++;
        return messageId;
    }

    function getMessage(uint groupId, uint messageId) public view returns(string memory) {
        if (groups[groupId].messages[messageId].sender != address(0)) {
            return groups[groupId].messages[messageId].content;
        }

        revert("Message not found");
    }
}
