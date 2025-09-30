//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
	*@title Contrato Donations
	*@notice Este es un contrato con fines educativos.
	*@author Alan Gutierrez.
	*@custom:security No usar en producción.
*/
contract KipuBank {

	/*///////////////////////
					Variables
	///////////////////////*/
	///@notice variable inmutable para almacenar la dirección que debe retirar los depósitos
	address immutable i_usuario;
	///@notice variable inmutable para indicar el valor límite de retiros (wei).
	uint256 immutable i_limite;
	///@notice variable inmutable para indicar el valor límite de depósitos (wei).
	uint256 immutable i_bankCap;
	/// @notice Mapping que almacena el balance de la bóveda por usuario (wei).
    mapping(address => uint256) private s_balances;
    /// @notice Total acumulado depositado en el contrato (wei).
    uint256 public s_totalDepositado;
    /// @notice Total acumulado retirado desde el contrato (wei).
    uint256 public s_totalRetirado;
    /// @notice Conteo global de depósitos exitosos.
    uint256 public s_depositosExitosos;
    /// @notice Conteo global de retiros exitosos.
    uint256 public s_retirosExitosos;
    /// @notice Conteo de depósitos por usuario.
    mapping(address => uint256) public s_depositosPorUsuario;
    /// @notice Conteo de retiros por usuario.
    mapping(address => uint256) public s_retirosPorUsuario;

	/*///////////////////////
						Events
	////////////////////////*/
	///@notice evento emitido cuando se realiza un nuevo depósito
	event KipuBank_DepositoRecibido(address usuario, uint256 valor, uint256 nuevoSaldo);
	///@notice evento emitido cuando se realiza un retiro
    event KipuBank_RetiroRealizado(address usuario, uint256 valor, uint256 nuevoSaldo);
	
	/*///////////////////////
						Errors
	///////////////////////*/
	/// @notice Se lanza si el depósito excede el cap global.
    error KipuBank_BankCapExcedido(uint256 intento, uint256 bankCap);
    /// @notice Se lanza si el retiro excede el límite por transacción.
    error KipuBank_ExcedeLimiteRetiro(uint256 intento, uint256 limiteRetiro);
    /// @notice Se lanza si el usuario no tiene saldo suficiente.
    error KipuBank_SaldoInsuficiente(uint256 saldo, uint256 saldoSolicitado);
	///@notice error emitido cuando falla una transacción
    error KipuBank_TransaccionFallida(address usuario, uint256 valor, bytes error);
	///@notice error emitido cuando el valor a depositar es menor o igual a cero
    error KipuBank_ValorDepositoMenorIgualACero(uint256 valor);
	///@notice error emitido cuando el valor a retirar es menor o igual a cero
    error KipuBank_ValorRetiroMenorIgualACero(uint256 valor);

	/*///////////////////////////////////
            			Modifiers
	///////////////////////////////////*/
	/// @notice Requiere que msg.value > 0 (para funciones payable).
    modifier ValorMayorACero() {
        if (msg.value <= 0) revert KipuBank_ValorDepositoMenorIgualACero(msg.value);
        _;
    }
	/*///////////////////////
					Functions
	///////////////////////*/
	constructor(address _usuario, uint256 _limiteRetiro, uint256 _bankCap){
		i_usuario = _usuario;
		i_limite = _limiteRetiro;
        i_bankCap = _bankCap;
	}
	
	///@notice función para recibir ether directamente
	receive() external payable{
		this.depositar();
	}
	fallback() external{}
	
	/**
		*@notice función para depósitos
		*@dev esta función debe sumar el valor depositado a lo largo del tiempo
		*@dev esta función debe emitir un evento informando el depósito.
	*/
	function depositar() external payable ValorMayorACero{
		uint256 nuevoTotal = s_totalDepositado + msg.value;
        if (nuevoTotal > i_bankCap) {
            revert KipuBank_BankCapExcedido(nuevoTotal, i_bankCap);
        }
        s_balances[msg.sender] += msg.value;
        s_totalDepositado = nuevoTotal;
        s_depositosExitosos += 1;
        s_depositosPorUsuario[msg.sender] += 1;
		emit KipuBank_DepositoRecibido(msg.sender, msg.value, s_balances[msg.sender]);
	}
	
	/*
	*@notice función para retirar el valor de saldo en la cuenta
	*@notice el valor del retiro debe ser mayor a cero y menor al límite de extracción
	*@dev solo el usuario permitido puede retirar
	*@param _valor El valor de la nota fiscal
	*/
	function retiro(uint256 _valor) external {
    	//if (msg.sender != i_usuario) revert KipuBank_UsuarioNoAutorizado(msg.sender, i_usuario);
		if (_valor == 0) revert KipuBank_ValorRetiroMenorIgualACero(_valor);
		if (_valor > i_limite) revert KipuBank_ExcedeLimiteRetiro(_valor, i_limite);
		if (_valor > s_balances[msg.sender]) revert KipuBank_SaldoInsuficiente(s_balances[msg.sender], _valor);

		s_balances[msg.sender] -= _valor;
		s_totalRetirado += _valor;
		s_retirosExitosos += 1;
		s_retirosPorUsuario[msg.sender] += 1;

		emit KipuBank_RetiroRealizado(msg.sender, _valor, s_balances[msg.sender]);

		_transferirEth(_valor);
	}
	
	/**
		*@notice función privada para realizar la transferencia del ether
		*@param _valor El valor a ser transferido
		*@dev debe revertir si falla
	*/
	function _transferirEth(uint256 _valor) private {
		(bool exito, bytes memory error) = msg.sender.call{value: _valor}("");
		if(!exito) revert KipuBank_TransaccionFallida(msg.sender, _valor, error);
	}

	/**
		@notice Retorna el balance de la cuenta del usuario.
		@param _usuario La dirección del usuario.
	*/
    function verSaldo(address _usuario) external view returns (uint256) {
        return s_balances[_usuario];
    }
}
