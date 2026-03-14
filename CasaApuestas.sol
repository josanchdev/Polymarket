// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importamos el token que creamos en el Paso 2
import "./ApuestasToken.sol";

contract CasaApuestas {
    address public owner;
    ApuestasToken public token; // Referencia a nuestro token ERC20

    // Simplificamos el precio de cada ficha a 0.01 ETH para facilitar las pruebas
    uint256 public precioFicha = 0.01 ether; 
    uint256 public nextEventoId = 1;

    // Estructuras de datos
    struct Apuesta {
        uint256 cantidad;
        bool apuestaA; // true = gana A, false = gana B
    }

    struct Evento {
        string descripcion;
        bool resuelto;
        bool ganadorA;
        uint256 totalA;
        uint256 totalB;
        address[] jugadores;
        mapping(address => Apuesta) apuestas;
    }

    mapping(uint256 => Evento) private _eventos;

    // Eventos para el registro de la blockchain
    event FichasCompradas(address indexed jugador, uint256 cantidad);
    event ApuestaRealizada(address indexed jugador, uint256 eventoId, uint256 cantidad, bool apuestaA);
    event EventoResuelto(uint256 indexed eventoId, bool ganadorA);
    event PremioRepartido(address indexed jugador, uint256 premio);

    modifier soloOwner() {
        require(msg.sender == owner, "Solo el owner de la casa puede hacer esto");
        _;
    }

    // ======= Constructor: Cumple el requisito principal =======
    // Aquí inicializamos las propiedades del token como pide el profesor
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) {
        owner = msg.sender; // El dueño de la casa eres tú (quien despliega)
        
        // La Casa de Apuestas despliega el token. 
        // Pasamos 0 como initialSupply para que el casino empiece sin fichas impresas.
        token = new ApuestasToken(tokenName, tokenSymbol, tokenDecimals, 0);
    }

    // ======= Justificación del MINT =======
    // Un jugador manda ETH para comprar fichas. La casa "mintea" (crea) esos tokens para él.
    function comprarFichas(uint256 cantidad) external payable {
        require(cantidad > 0, "Debes comprar al menos 1 ficha");
        require(msg.value >= precioFicha * cantidad, "ETH insuficiente enviado");

        // La Casa llama a la función exclusiva de minteo del token
        token.ownerMint(msg.sender, cantidad);
        emit FichasCompradas(msg.sender, cantidad);
    }

    // El owner del casino crea un partido (Ej: "Real Madrid vs Barcelona")
    function crearEvento(string calldata descripcion) external soloOwner returns (uint256) {
        uint256 id = nextEventoId++;
        Evento storage ev = _eventos[id];
        ev.descripcion = descripcion;
        return id;
    }

    // ======= Justificación del BURN =======
    // Al apostar, el jugador "congela" o arriesga sus fichas. Se las quemamos de su saldo.
    function apostar(uint256 eventoId, uint256 cantidad, bool apuestaA) external {
        require(cantidad > 0, "La apuesta debe ser mayor a 0");
        require(!_eventos[eventoId].resuelto, "El evento ya termino");
        require(_eventos[eventoId].apuestas[msg.sender].cantidad == 0, "Ya has apostado en este evento");

        // Usamos la función de quemado remoto que preparamos en el Token
        // Si el usuario no tiene saldo, esta llamada fallará gracias al require heredado del ERC20Padre
        token.ownerBurn(msg.sender, cantidad);

        // Guardamos la apuesta
        Evento storage ev = _eventos[eventoId];
        ev.apuestas[msg.sender] = Apuesta(cantidad, apuestaA);
        ev.jugadores.push(msg.sender);

        if (apuestaA) {
            ev.totalA += cantidad;
        } else {
            ev.totalB += cantidad;
        }

        emit ApuestaRealizada(msg.sender, eventoId, cantidad, apuestaA);
    }

    // ======= Justificación extra del MINT =======
    // Se termina el partido. A los que acertaron, se les "mintea" de vuelta su apuesta más su beneficio.
    // Los que perdieron, se quedan sin nada (sus tokens ya fueron quemados al apostar).
    function resolverEvento(uint256 eventoId, bool ganadorA) external soloOwner {
        Evento storage ev = _eventos[eventoId];
        require(!ev.resuelto, "El evento ya fue resuelto");

        ev.resuelto = true;
        ev.ganadorA = ganadorA;

        uint256 totalGanadores = ganadorA ? ev.totalA : ev.totalB;
        uint256 totalPerdedores = ganadorA ? ev.totalB : ev.totalA;

        emit EventoResuelto(eventoId, ganadorA);

        // Si nadie ganó, no se mintea nada nuevo
        if (totalGanadores == 0) return;

        // Repartimos premios
        for (uint256 i = 0; i < ev.jugadores.length; i++) {
            address jugador = ev.jugadores[i];
            Apuesta memory apuesta = ev.apuestas[jugador];

            if (apuesta.apuestaA == ganadorA) {
                // Cálculo del premio: lo que apostó + parte proporcional del dinero de los perdedores
                uint256 premio = apuesta.cantidad;
                if (totalPerdedores > 0) {
                    premio += (apuesta.cantidad * totalPerdedores) / totalGanadores;
                }
                
                // Entregamos el premio minteando nuevos tokens al ganador
                token.ownerMint(jugador, premio);
                emit PremioRepartido(jugador, premio);
            }
        }
    }

    // Permite al dueño del casino retirar las ganancias en ETH de las fichas vendidas
    function retirarETH() external soloOwner {
        payable(owner).transfer(address(this).balance);
    }
}