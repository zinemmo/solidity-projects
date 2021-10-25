// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

interface DateTimeAPI {
        /*
         *  Interface contract for interfacing with the DateTime contract.
         *
         */
        function isLeapYear(uint16 year) external pure returns (bool);
        function getYear(uint timestamp) external pure returns (uint16);
        function getMonth(uint timestamp) external pure returns (uint8);
        function getDay(uint timestamp) external pure returns (uint8);
        function getHour(uint timestamp) external pure returns (uint8);
        function getMinute(uint timestamp) external pure returns (uint8);
        function getSecond(uint timestamp) external pure returns (uint8);
        function getWeekday(uint timestamp) external pure returns (uint8);
        function toTimestamp(uint16 year, uint8 month, uint8 day) external pure returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) external pure returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) external pure returns (uint timestamp);
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) external pure returns (uint timestamp);
}

