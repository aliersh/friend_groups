// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {BadFriendGroups} from "../src/BadFriendGroups.sol";

contract BadFriendGroupsTest is Test {
    BadFriendGroups public badFriendGroups;
    uint public groupId;
    address public member;
    string constant GROUP_NAME = "Enemies";

    // Setup function runs before each test to initialize contract instance
    function setUp() public {
        badFriendGroups = new BadFriendGroups();
        member = address(this);
    }

    // Helper function to create a test group and return its ID
    function _createTestGroup() internal returns (uint) {
        groupId = badFriendGroups.createGroup(GROUP_NAME);
        return groupId;
    }

    // Helper function to add a test member to the created group
    function _addTestMember() internal {
        badFriendGroups.addMember(groupId, member);
    }

    // Test group creation with a valid name
    function test_createGroup() public {
        uint groupIdEnemies = _createTestGroup();
        uint groupIdBosses = badFriendGroups.createGroup("Bosses");

        assertEq(
            badFriendGroups.getGroupName(groupIdEnemies),
            GROUP_NAME,
            "Group name should be stored correctly"
        );
        assertEq(
            badFriendGroups.getOwner(groupIdEnemies),
            member,
            "Owner should be msg.sender"
        );
        assertEq(badFriendGroups.getGroupName(groupIdBosses), "Bosses");
    }

    // Test that creating a group with an empty name fails
    function test_createGroupFail() public {
        vm.expectRevert("Name cannot be empty");
        badFriendGroups.createGroup("");
    }

    // Test group deletion and verify that group doesn't exist
    function test_deleteGroup() public {
        groupId = _createTestGroup();
        badFriendGroups.deleteGroup(groupId);

        vm.expectRevert("Group doesn't exist");
        badFriendGroups.getGroupName(groupId);
    }

    // Test adding a member to a group and preventing duplicate additions
    function test_addMember() public {
        groupId = _createTestGroup();
        _addTestMember();

        assertTrue(
            badFriendGroups.isMember(groupId, member),
            "Should be a member"
        );

        vm.expectRevert("Member is already in the group");
        badFriendGroups.addMember(groupId, member);
    }

    // Test removing a member and preventing removal of non-existent members
    function test_removeMember() public {
        groupId = _createTestGroup();
        _addTestMember();

        badFriendGroups.removeMember(groupId, member);
        assertFalse(
            badFriendGroups.isMember(groupId, member),
            "Shouldn't be a member"
        );

        vm.expectRevert("Member doesn't exist");
        badFriendGroups.removeMember(groupId, member);
    }

    // Test that deleting a group removes all members and resets state
    function test_noMembersGroup() public {
        groupId = _createTestGroup();
        _addTestMember();

        badFriendGroups.deleteGroup(groupId);
        uint newGroupId = _createTestGroup();
        assertFalse(
            badFriendGroups.isMember(newGroupId, member),
            "Group shouldn't have members"
        );
    }

    // Test the message system, ensuring only members can send messages
    function test_messageSystem() public {
        groupId = _createTestGroup();

        // Expect revert when a non-member tries to send a message
        vm.expectRevert();
        badFriendGroups.writeMessage(groupId, member, "message");

        // Add member and send a valid message
        _addTestMember();
        uint messageId = badFriendGroups.writeMessage(
            groupId,
            member,
            "message"
        );
        string memory content = badFriendGroups.getMessage(groupId, messageId);
        assertEq(content, "message", "Message content should match");

        // Expect revert when sending an empty message
        vm.expectRevert("Message cannot be empty");
        badFriendGroups.writeMessage(groupId, member, "");

        // Expect revert when retrieving a non-existent message
        vm.expectRevert();
        badFriendGroups.getMessage(groupId, messageId + 1);
    }
}
