// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SystemCard.sol";
import "./MyCryptoToken.sol";

contract GachaSystem is Ownable {
    SystemCard public systemCard;
    MyCryptoToken public myCryptoToken;
    uint256 public gachaPrice;

    struct Event {
        string name;
        uint256 startTime;
        uint256 endTime;
        uint256 commonChance;
        uint256 rareChance;
        uint256 uniqueChance;
        uint256 legacyChance;
        uint256 divineChance;
        bool active;
    }

    Event[] public events;

    constructor(SystemCard _systemCard, MyCryptoToken _myCryptoToken, uint256 _gachaPrice) {
        systemCard = _systemCard;
        myCryptoToken = _myCryptoToken;
        gachaPrice = _gachaPrice;
    }

    function addEvent(
        string memory name,
        uint256 startTime,
        uint256 endTime,
        uint256 commonChance,
        uint256 rareChance,
        uint256 uniqueChance,
        uint256 legacyChance,
        uint256 divineChance
    ) external onlyOwner {
        events.push(Event({
            name: name,
            startTime: startTime,
            endTime: endTime,
            commonChance: commonChance,
            rareChance: rareChance,
            uniqueChance: uniqueChance,
            legacyChance: legacyChance,
            divineChance: divineChance,
            active: true
        }));
    }

    function setEventStatus(uint256 eventId, bool status) external onlyOwner {
        require(eventId < events.length, "Invalid event ID");
        events[eventId].active = status;
    }

    function getCurrentEvent() internal view returns (Event memory) {
        for (uint256 i = 0; i < events.length; i++) {
            if (block.timestamp >= events[i].startTime && block.timestamp <= events[i].endTime && events[i].active) {
                return events[i];
            }
        }
        return Event("", 0, 0, 0, 0, 0, 0, 0, false); // No active event
    }

    function drawGacha() external {
        require(myCryptoToken.transferFrom(msg.sender, address(this), gachaPrice), "Token transfer failed");

        Event memory currentEvent = getCurrentEvent();
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000;
        SystemCard.Rarity rarity;

        if (currentEvent.active) {
            uint256 totalChance = currentEvent.commonChance + currentEvent.rareChance + currentEvent.uniqueChance + currentEvent.legacyChance + currentEvent.divineChance;
            require(totalChance <= 1000, "Invalid event chances");

            if (random < currentEvent.commonChance) {
                rarity = SystemCard.Rarity.Common;
            } else if (random < currentEvent.commonChance + currentEvent.rareChance) {
                rarity = SystemCard.Rarity.Rare;
            } else if (random < currentEvent.commonChance + currentEvent.rareChance + currentEvent.uniqueChance) {
                rarity = SystemCard.Rarity.Unique;
            } else if (random < currentEvent.commonChance + currentEvent.rareChance + currentEvent.uniqueChance + currentEvent.legacyChance) {
                rarity = SystemCard.Rarity.Legacy;
            } else {
                rarity = SystemCard.Rarity.Divine;
            }
        } else {
            if (random < 700) { // 70% chance
                rarity = SystemCard.Rarity.Common;
            } else if (random < 900) { // 20% chance (70% + 20% = 90%)
                rarity = SystemCard.Rarity.Rare;
            } else if (random < 979) { // 7.9% chance (90% + 7.9% = 97.9%)
                rarity = SystemCard.Rarity.Unique;
            } else if (random < 999) { // 2% chance (97.9% + 2% = 99.9%)
                rarity = SystemCard.Rarity.Legacy;
            } else { // 0.1% chance (99.9% + 0.1% = 100%)
                rarity = SystemCard.Rarity.Divine;
            }
        }

        // Mint the card
        systemCard.mintCard(msg.sender, "TokenURI placeholder", rarity);
    }
}
