pragma solidity >=0.5.0;

interface IWALM {
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}