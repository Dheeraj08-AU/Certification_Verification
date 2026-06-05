// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificateVerification {

    address public owner;

    // Array to track all unique certificate IDs for registry retrieval
    string[] private certificateIds;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _; // Fixed the typo here
    }

    struct Certificate {
        string studentName;
        string courseName;
        string issueDate;
        string certificateId;
        bool isValid;
    }

    mapping(string => Certificate) private certificates;

    event CertificateIssued(
        string certificateId,
        string studentName,
        string courseName
    );

    event CertificateRevoked(string certificateId);

    function issueCertificate(
        string memory _studentName,
        string memory _courseName,
        string memory _issueDate,
        string memory _certificateId
    ) public onlyOwner {

        require(
            bytes(certificates[_certificateId].certificateId).length == 0,
            "Certificate already exists"
        );

        // Save the certificate data into the mapping
        certificates[_certificateId] = Certificate(
            _studentName,
            _courseName,
            _issueDate,
            _certificateId,
            true
        );

        // Store the ID into our tracking array
        certificateIds.push(_certificateId);

        emit CertificateIssued(
            _certificateId,
            _studentName,
            _courseName
        );
    }

    function verifyCertificate(
        string memory _certificateId
    )
        public
        view
        returns (
            string memory studentName,
            string memory courseName,
            string memory issueDate,
            bool isValid
        )
    {
        Certificate memory cert = certificates[_certificateId];

        return (
            cert.studentName,
            cert.courseName,
            cert.issueDate,
            cert.isValid
        );
    }

    function revokeCertificate(
        string memory _certificateId
    ) public onlyOwner {

        require(
            bytes(certificates[_certificateId].certificateId).length > 0,
            "Certificate does not exist"
        );

        // Flips the valid status to false inside the mapping
        certificates[_certificateId].isValid = false;

        emit CertificateRevoked(_certificateId);
    }

    /**
     * @notice Fetches every certificate record dynamically from the blockchain.
     * @return An array of Certificate structs with real-time validity states.
     */
    function getAllCertificates() public view returns (Certificate[] memory) {
        uint256 total = certificateIds.length;
        Certificate[] memory allCerts = new Certificate[](total);

        // Loop through all saved IDs and grab their latest status from the mapping
        for (uint256 i = 0; i < total; i++) {
            allCerts[i] = certificates[certificateIds[i]];
        }

        return allCerts;
    }
}