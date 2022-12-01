# Introduccion a dApps en Solidity - Ejercicio integrador

Ejercicio integrador de empresa encargada de vender entradas para eventos

Cuenta con 3 contratos 
- Manager.sol
- Ticket.sol
- MyERC721Token.sol

Se utilizó la suit de Truffle/Ganache para el desarrollo y testeo local, se realizon units test, principalmente en el contrato `Manager.sol`, y se desarrollanron 2 scritps, uno para compilar y desplegar en local, y otro scritp para desplegar el contrato en Goerli Testnet Network.  

Scripts
====

- Compilar y desplegar en tesnet local de truffle
    ```
        ./scripts/deployTestingAnRunTest.sh
    ```

- Desplegar en Goerli Testnet Network
    ```
        ./scripts/deployGoerli.sh
    ```

Goerli Testnet Network
====

- Contrato descplegado en Goerli Etherscan [0xFfd2016c95d0758534ca4cF23Df8bCd8d05dfD34](https://goerli.etherscan.io/address/0xFfd2016c95d0758534ca4cF23Df8bCd8d05dfD34)


Contact
=====
Christian Mereles chmereles@gmail.com
