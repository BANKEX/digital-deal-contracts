pragma solidity ^0.4.0;

/// @title The primary persistent storage for Rocket Pool
/// @author David Rugendyke
contract EternalStorage {

    /**** Storage Types *******/

    address public owner;

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => uint8)      private uInt8Storage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;
    mapping(bytes32 => bytes32)    private bytes32Storage;


    /*** Modifiers ************/

    /// @dev Only allow access from the latest version of a contract in the Rocket Pool network after deployment
    modifier onlyLatestContract() {
        require(addressStorage[keccak256("contract.address", msg.sender)] != 0x0 || msg.sender == owner);
        _;
    }

    /// @dev constructor
    function EternalStorage() public {
        owner = msg.sender;
        addressStorage[keccak256("contract.address", msg.sender)] = msg.sender;
    }

    function setOwner() public {
        require(msg.sender == owner);
        addressStorage[keccak256("contract.address", owner)] = 0x0;
        owner = msg.sender;
        addressStorage[keccak256("contract.address", msg.sender)] = msg.sender;
    }

    /**** Get Methods ***********/

    /// @param _key The key for the record
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    /// @param _key The key for the record
    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

      /// @param _key The key for the record
    function getUint8(bytes32 _key) external view returns (uint8) {
        return uInt8Storage[_key];
    }


    /// @param _key The key for the record
    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes32(bytes32 _key) external view returns (bytes32) {
        return bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    /// @param _key The key for the record
    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Set Methods ***********/

    /// @param _key The key for the record
    function setAddress(bytes32 _key, address _value) onlyLatestContract external {
        addressStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint(bytes32 _key, uint _value) onlyLatestContract external {
        uIntStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint8(bytes32 _key, uint8 _value) onlyLatestContract external {
        uInt8Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setString(bytes32 _key, string _value) onlyLatestContract external {
        stringStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes(bytes32 _key, bytes _value) onlyLatestContract external {
        bytesStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes32(bytes32 _key, bytes32 _value) onlyLatestContract external {
        bytes32Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBool(bytes32 _key, bool _value) onlyLatestContract external {
        boolStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setInt(bytes32 _key, int _value) onlyLatestContract external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods ***********/

    /// @param _key The key for the record
    function deleteAddress(bytes32 _key) onlyLatestContract external {
        delete addressStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint(bytes32 _key) onlyLatestContract external {
        delete uIntStorage[_key];
    }

     /// @param _key The key for the record
    function deleteUint8(bytes32 _key) onlyLatestContract external {
        delete uInt8Storage[_key];
    }

    /// @param _key The key for the record
    function deleteString(bytes32 _key) onlyLatestContract external {
        delete stringStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes(bytes32 _key) onlyLatestContract external {
        delete bytesStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes32(bytes32 _key) onlyLatestContract external {
        delete bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function deleteBool(bytes32 _key) onlyLatestContract external {
        delete boolStorage[_key];
    }

    /// @param _key The key for the record
    function deleteInt(bytes32 _key) onlyLatestContract external {
        delete intStorage[_key];
    }
}
