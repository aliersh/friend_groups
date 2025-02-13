// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {GoodFriendGroups} from "../src/GoodFriendGroups.sol";

contract GoodFriendGroupsTest is Test {
    GoodFriendGroups public goodFriendGroups;
    uint public groupId;
    address public member;
    string constant GROUP_NAME = "Friends";

    // Setup function runs before each test to initialize contract instance
    function setUp() public {
        goodFriendGroups = new GoodFriendGroups();
        member = address(this);
    }

    // Helper function to create a test group and return its ID
    function _createTestGroup() internal returns (uint) {
        groupId = goodFriendGroups.createGroup(GROUP_NAME);
        return groupId;
    }

    // Helper function to add a test member to the created group
    function _addTestMember() internal {
        goodFriendGroups.addMember(groupId, member);
    }

    // Test group creation with a valid name
    function test_createGroup() public {
        uint groupIdFriends = _createTestGroup();
        uint groupIdWork = goodFriendGroups.createGroup("Work");
        
        assertEq(goodFriendGroups.getGroupName(groupIdFriends), GROUP_NAME, "Group name should be stored correctly");
        assertEq(goodFriendGroups.getOwner(groupIdFriends), member, "Owner should be msg.sender");
        assertEq(goodFriendGroups.getGroupName(groupIdWork), "Work");
    }

    // Test that creating a group with an empty name fails
    function test_createGroupFail() public {
        vm.expectRevert("Name cannot be empty");
        goodFriendGroups.createGroup("");
    }

    // Test group deletion and verify that data is reset
    function test_deleteGroup() public {
        groupId = _createTestGroup();
        goodFriendGroups.deleteGroup(groupId);
        
        assertEq(goodFriendGroups.getGroupName(groupId), "");
        assertEq(goodFriendGroups.getOwner(groupId), address(0));
    }

    // Test adding a member to a group and preventing duplicate additions
    function test_addMember() public {
        groupId = _createTestGroup();
        _addTestMember();
        
        assertTrue(goodFriendGroups.isMember(groupId, member), "Should be a member");

        vm.expectRevert("Member is already in the group");
        goodFriendGroups.addMember(groupId, member);
    }

    // Test removing a member and preventing removal of non-existent members
    function test_removeMember() public {
        groupId = _createTestGroup();
        _addTestMember();
        
        goodFriendGroups.removeMember(groupId, member);
        assertFalse(goodFriendGroups.isMember(groupId, member), "Shouldn't be a member");

        vm.expectRevert("Member doesn't exist");
        goodFriendGroups.removeMember(groupId, member);
    }

    // Test that deleting a group removes all members and resets state
    function test_noMembersGroup() public {
        groupId = _createTestGroup();
        _addTestMember();
        
        goodFriendGroups.deleteGroup(groupId);
        uint newGroupId = _createTestGroup();
        assertFalse(goodFriendGroups.isMember(newGroupId, member), "Group shouldn't have members");
    }

    // Test the message system, ensuring only members can send messages
    function test_messageSystem() public {
        groupId = _createTestGroup();

        // Expect revert when a non-member tries to send a message
        vm.expectRevert();
        goodFriendGroups.writeMessage(groupId, member, "message");

        // Add member and send a valid message
        _addTestMember();
        uint messageId = goodFriendGroups.writeMessage(groupId, member, "message");
        string memory content = goodFriendGroups.getMessage(groupId, messageId);
        assertEq(content, "message", "Message content should match");

        // Expect revert when sending an empty message
        vm.expectRevert("Message cannot be empty");
        goodFriendGroups.writeMessage(groupId, member, "");

        // Expect revert when retrieving a non-existent message
        vm.expectRevert();
        goodFriendGroups.getMessage(groupId, messageId + 1);
    }
}
