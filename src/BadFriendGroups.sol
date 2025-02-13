// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BadFriendGroups {
    struct Group {
        uint id;
        string name;
        address owner;
        address[] members;
        Message[] messages;
    }

    struct Message {
        uint id;
        address sender;
        string content;
    }

    Group[] public groups;
    uint256 private groupCounter;
    uint private messageCounter;
    mapping(uint => uint) private idToIndex; //Maybe I'm cheating here xd

    function _retrieveIndex(uint groupId) internal view returns(uint) {
        require(idToIndex[groupId] < groups.length, "Group doesn't exist");
        return idToIndex[groupId];
    }

    //I need to understand clearly why is not possible to initialize the group inside the push. Storage problem with the message struct array
    function createGroup(string memory name) public {
        require(bytes(name).length > 0, "Name cannot be empty");
        groups.push();
        Group storage newGroup = groups[groups.length - 1]; //This is the key, a pointer, a reference, right?
        uint newGroupId = groupCounter;
        newGroup.id = newGroupId;
        newGroup.name = name;
        newGroup.owner = msg.sender;

        idToIndex[newGroupId] = groups.length - 1;
        groupCounter++;
    }

    function deleteGroup(uint groupId) public {
        uint index = _retrieveIndex(groupId);
        groups[index] = groups[groups.length - 1];
        idToIndex[groups[index].id] = index;
        groups.pop();
        delete idToIndex[groupId];
    }

    function addMember(uint groupId, address member) public {
        require(isMember(groupId, member), "Member is already in the group");
        uint index = _retrieveIndex(groupId);
        groups[index].members.push(member);
    }

    function removeMember(uint groupId, address member) public {
        require(isMember(groupId, member), "Member doesn't exist");
        uint index = _retrieveIndex(groupId);
        Group storage group = groups[index]; //I tried to do directly like groups[index].members[i]. Inneficient? Create a reference is better

        for (uint i = 0; i < group.members.length; i++) {
            if (group.members[i] == member) {
                group.members[i] = group.members[group.members.length - 1];
                group.members.pop();
                break;
            }
        }
    }

    function getOwner(uint groupId) public view returns(address) {
        uint index = _retrieveIndex(groupId);
        return groups[index].owner;
    }

    function isMember(uint groupId, address member) public view returns(bool) {
        uint index = _retrieveIndex(groupId);
        Group storage group = groups[index];

        for (uint i = 0; i < group.members.length; i++) {
            if (group.members[i] == member) {
                return true;
            }
        }

        return false;
    }

    function writeMessage(uint groupId, string memory _content) public {
        require(bytes(_content).length > 0, "Message cannot be empty");
        uint index = _retrieveIndex(groupId);
        Group storage group = groups[index];

        group.messages.push();
        Message storage newMessage = group.messages[group.messages.length - 1];

        newMessage.id = messageCounter;
        newMessage.sender = msg.sender;
        newMessage.content = _content;

        messageCounter++;
    }

    function getMessage(uint groupId, uint messageId) public view returns(string memory) {
        uint index = _retrieveIndex(groupId);
        Group storage group = groups[index];

        for (uint i = 0; i < group.messages.length; i++) {
            if (group.messages[i].id == messageId) {
                return group.messages[i].content;
            }
        }

        revert("Message not found");
    }
}