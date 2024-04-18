DROP DATABASE IF EXISTS PROYECTO;
CREATE DATABASE PROYECTO;
USE PROYECTO;

-- Normativa
CREATE TABLE Normativa (
			idNormativa int NOT NULL AUTO_INCREMENT,
			linkPlantilla TEXT NOT NULL,
			descripcionNormativa MEDIUMTEXT NOT NULL,
			fecha DATETIME NOT NULL DEFAULT NOW(),
			esVigente BOOLEAN NOT NULL,
            
			PRIMARY KEY (idNormativa)
			);
-- Unidad
CREATE TABLE Unidad (
			  idUnidad int NOT NULL AUTO_INCREMENT,
			  nombreUnidad varchar(100) NOT NULL,
			  extension int NOT NULL,
			  correo varchar(100) NOT NULL,
	
			  PRIMARY KEY (idUnidad)
			  );

-- Tramite
CREATE TABLE Tramite (
			idTramite int NOT NULL AUTO_INCREMENT,
			idUnidad int NOT NULL,
			idNormativa int NOT NULL,
			nombre varchar(200) NOT NULL,
			descripcion TEXT NOT NULL,
			costo decimal(12,2) DEFAULT NULL,
            
			PRIMARY KEY (idTramite),
            FOREIGN KEY(idUnidad) REFERENCES unidad(idunidad),
            FOREIGN KEY (idNormativa) REFERENCES normativa(idNormativa)
);

CREATE TABLE Usuario 	(
			idUsuario INT NOT NULL AUTO_INCREMENT,
			identificacion INT NOT NULL,
			tipo ENUM('Administrativo','Estudiante','Docente','Empleado') NOT NULL,
			nombre VARCHAR(100) NOT NULL,
			apellido VARCHAR(100) NOT NULL,
			correoElectronico VARCHAR(200) NOT NULL,
			telefono BIGINT NOT NULL,
            sexo ENUM('H','M','O'),
			
			PRIMARY KEY(idUsuario),
			UNIQUE(identificacion,tipo)
			);

-- Solicitud
CREATE TABLE Solicitud (
			idSolicitud INT NOT NULL AUTO_INCREMENT,
			idUsuario INT NOT NULL,
			idFuncionario INT NOT NULL,
			idTramite INT NOT NULL,
			estado ENUM('pendiente','en proceso','completado','cerrado','cancelado') NOT NULL DEFAULT 'PENDIENTE',
			fechaInicio DATETIME NOT NULL DEFAULT NOW(),
			
			PRIMARY KEY(idSolicitud),
			FOREIGN KEY(idUsuario) REFERENCES usuario(idUsuario),       
			FOREIGN KEY(idFuncionario) REFERENCES usuario(idUsuario),
			FOREIGN KEY(idTramite) REFERENCES tramite(idTramite)
			);
             
-- Documento:
CREATE TABLE Documento (
			idDocumento INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
			tipoDocumento ENUM('ReciboDePago','Operacion','Solicitado') NOT NULL,
			tituloDocumento VARCHAR(100) NOT NULL,
			linkDocumento TEXT NOT NULL,
			estadoDocumento ENUM('activo','inactivo') NOT NULL,


			PRIMARY KEY(idDocumento),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
                        );
-- CONSTRAINTS                    
-- Pago:
CREATE TABLE Pago (
			idPago INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
			estadoDePago ENUM('Pagado','Por Pagar') NOT NULL,
			fechaInicio DATE NOT NULL,
			fechaLimite DATE NOT NULL,
			fechaDeCancelacion DATE NULL,
			monto DECIMAL(12,2) NOT NULL,
			
			PRIMARY KEY(idPago),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
                        );
                        
ALTER TABLE PAGO ADD CONSTRAINT revisarFechas CHECK (fechaInicio<=FechaLimite);    

-- Comentario:
CREATE TABLE Comentario(
			idComentario INT NOT NULL AUTO_INCREMENT,
			idSolicitud INT NOT NULL,
			idUsuario INT NOT NULL,
			comentarioAnterior INT NULL,
			mensaje MEDIUMTEXT NOT NULL,
			fechaYhora DATETIME NOT NULL DEFAULT NOW(),
			
			PRIMARY KEY(idComentario),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud),
			FOREIGN KEY (idUsuario) REFERENCES usuario(idUsuario),
			FOREIGN KEY (comentarioAnterior) REFERENCES comentario(idComentario));
            
-- Cancelacion:
CREATE TABLE cancelacion (
	
    idCancelacion INT NOT NULL AUTO_INCREMENT,
    idSolicitud INT NOT NULL,
    tipo VARCHAR(50),
    fecha DATETIME NOT NULL,
    PRIMARY KEY (idCancelacion),
    CONSTRAINT relacion_idSolicitud FOREIGN KEY (idSolicitud) REFERENCES solicitud(idSolicitud)
    
);
                    
