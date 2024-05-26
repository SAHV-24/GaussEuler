DROP DATABASE IF EXISTS PROYECTO;
CREATE DATABASE PROYECTO;
USE PROYECTO;

-- Unidad
CREATE TABLE Unidad (
			  idUnidad int NOT NULL AUTO_INCREMENT,
			  nombreUnidad varchar(100) NOT NULL,
			  extension int NOT NULL,
			  correo varchar(100) NOT NULL,
	
			  PRIMARY KEY (idUnidad)
			  );
ALTER TABLE unidad ADD CONSTRAINT checkExtension CHECK(extension<100000);
ALTER TABLE unidad ADD CONSTRAINT checkCorreoUnidad CHECK(correo LIKE '%@%');


-- Tramite
CREATE TABLE Tramite (
			idTramite int NOT NULL AUTO_INCREMENT,
			idUnidad int NOT NULL,
			linkPlantilla TEXT NOT NULL,
			nombre varchar(200) NOT NULL,
			descripcion TEXT NOT NULL,
			costo decimal(12,2) DEFAULT NULL,
            
			PRIMARY KEY (idTramite),
            FOREIGN KEY(idUnidad) REFERENCES unidad(idunidad))
            ;

ALTER TABLE Tramite ADD CONSTRAINT revisarCosto CHECK (costo>=0);    
-- Normativa
CREATE TABLE Normativa (
			idNormativa int NOT NULL AUTO_INCREMENT,
            idTramite INT NOT NULL,
			descripcionNormativa MEDIUMTEXT NOT NULL,
			fecha DATETIME NOT NULL DEFAULT NOW(),
			esVigente BOOLEAN NOT NULL,
            
			PRIMARY KEY (idNormativa),
            FOREIGN KEY(idTRamite) REFERENCES tramite (idTramite)
			);
            
CREATE TABLE Usuario 	(
			idUsuario INT NOT NULL AUTO_INCREMENT,
			identificacion INT NOT NULL,
			tipo ENUM('Administrativo','Estudiante','Docente','Empleado') NOT NULL,
			nombre VARCHAR(100) NOT NULL,
			apellido VARCHAR(100) NOT NULL,
			correoElectronico VARCHAR(200) NOT NULL,
			telefono BIGINT NOT NULL,
            sexo ENUM('H','M') NOT NULL,
			
			PRIMARY KEY(idUsuario),
			UNIQUE(identificacion,tipo)
			);

ALTER TABLE Usuario ADD CONSTRAINT checkCorreoUsu CHECK(correoElectronico LIKE '%@%');

-- Solicitud
CREATE TABLE Solicitud (
			idSolicitud INT NOT NULL AUTO_INCREMENT,
			idUsuario INT NOT NULL,
			idFuncionario INT NOT NULL,
			idTramite INT NOT NULL,
			estado ENUM('pendiente','enProceso','completado','cerrado','cancelado') NOT NULL DEFAULT 'PENDIENTE',
			fechaInicio DATETIME NOT NULL DEFAULT NOW(),
			
			PRIMARY KEY(idSolicitud),
			FOREIGN KEY(idUsuario) REFERENCES usuario(idUsuario),       
			FOREIGN KEY(idFuncionario) REFERENCES usuario(idUsuario),
			FOREIGN KEY(idTramite) REFERENCES tramite(idTramite)
			);

ALTER TABLE solicitud ADD CONSTRAINT revisarEstados 
CHECK (ESTADO='pendiente' or estado='enproceso'or estado='completado'or estado='cerrado'or estado='cancelado');
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
			estadoDePago ENUM('Pagado','PorPagar') NOT NULL DEFAULT 'porPagar',
			fechaInicio DATE NOT NULL,
			fechaLimite DATE NOT NULL,
			saldadoEl DATE NULL,
			monto DECIMAL(12,2) NOT NULL,
			
			PRIMARY KEY(idPago),
			FOREIGN KEY(idSolicitud) REFERENCES solicitud(idSolicitud)
			);
                        
ALTER TABLE PAGO ADD CONSTRAINT revisarFechas CHECK (fechaInicio<=FechaLimite);   
ALTER TABLE PAGO ADD CONSTRAINT revisarMonto CHECK (MONTO>=0);    

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
                    
