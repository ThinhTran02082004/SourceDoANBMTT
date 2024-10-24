CREATE TABLE [Users] (
    ID NVARCHAR(20) PRIMARY KEY,         
    EMAIL NVARCHAR(100),                 
    PASSWORD VARBINARY(MAX) NOT NULL,   
    ROLE NVARCHAR(50),                 
    PHONE VARBINARY(MAX),                 
    FULL_NAME NVARCHAR(100) NOT NULL      
);

CREATE TABLE [Department] (
    ID NVARCHAR(20) PRIMARY KEY,         
    NAME NVARCHAR(100)                 
);

ALTER TABLE [Users]
ADD department_id NVARCHAR(20),
    CONSTRAINT FK_Department_Users FOREIGN KEY (department_id) REFERENCES [Department](ID);


CREATE SYMMETRIC KEY AESKey
WITH ALGORITHM = AES_128
ENCRYPTION BY PASSWORD = '05102024';

CREATE PROCEDURE SP_INS_ENCRYPT_USER
    @ID NVARCHAR(20),
    @EMAIL NVARCHAR(100),
    @PASSWORD NVARCHAR(100),
    @ROLE NVARCHAR(50),
    @PHONE NVARCHAR(20),
    @FULL_NAME NVARCHAR(100),
    @DEPARTMENT_ID NVARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        OPEN SYMMETRIC KEY AESKey DECRYPTION BY PASSWORD = '05102024';

        DECLARE @EncryptedPassword VARBINARY(MAX);
        DECLARE @EncryptedPhone VARBINARY(MAX);

        SET @EncryptedPassword = EncryptByKey(Key_GUID('AESKey'), @PASSWORD); 
        SET @EncryptedPhone = EncryptByKey(Key_GUID('AESKey'), @PHONE);

        INSERT INTO [Users] (ID, EMAIL, PASSWORD, ROLE, PHONE, FULL_NAME, department_id)
        VALUES (@ID, @EMAIL, @EncryptedPassword, @ROLE, @EncryptedPhone, @FULL_NAME, @DEPARTMENT_ID);

        CLOSE SYMMETRIC KEY AESKey;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;


CREATE PROCEDURE SP_SEL_DECRYPT_USER
AS
BEGIN
    OPEN SYMMETRIC KEY AESKey DECRYPTION BY PASSWORD = '05102024';

    SELECT 
        U.ID,
        U.EMAIL,
        U.ROLE,
        CONVERT(NVARCHAR(20), DecryptByKey(U.PHONE)) AS PHONE,
        U.FULL_NAME,
        D.NAME AS DEPARTMENT_NAME
    FROM [Users] U
    LEFT JOIN [Department] D ON U.department_id = D.ID;

    CLOSE SYMMETRIC KEY AESKey;
END;

CREATE PROCEDURE SP_LOGIN_USER
    @EMAIL NVARCHAR(100),
    @PASSWORD NVARCHAR(100)
AS
BEGIN
    DECLARE @EncryptedPhone VARBINARY(MAX);
    DECLARE @StoredEncryptedPassword VARBINARY(MAX);
    DECLARE @StoredEncryptedPhone VARBINARY(MAX);
    DECLARE @DecryptedPassword NVARCHAR(100);
    DECLARE @ID NVARCHAR(20);
    DECLARE @FULL_NAME NVARCHAR(100);
    DECLARE @ROLE NVARCHAR(50);  
    OPEN SYMMETRIC KEY AESKey DECRYPTION BY PASSWORD = '05102024';

    SELECT @StoredEncryptedPassword = [PASSWORD], 
           @StoredEncryptedPhone = [PHONE], 
           @ID = ID, 
           @FULL_NAME = FULL_NAME,
           @ROLE = ROLE  
    FROM Users
    WHERE EMAIL = @EMAIL;

    IF @StoredEncryptedPassword IS NOT NULL
    BEGIN
        SET @DecryptedPassword = CONVERT(NVARCHAR(100), DecryptByKey(@StoredEncryptedPassword));

        IF @DecryptedPassword = @PASSWORD
        BEGIN
            IF @ROLE = 'admin'
            BEGIN
                SELECT @ID AS MANV, @FULL_NAME AS HOTEN; 
            END
            ELSE
            BEGIN
                RAISERROR('Quyền của bạn là %s', 16, 1, @ROLE);
            END
        END
        ELSE
        BEGIN
            RAISERROR('Mật khẩu không chính xác.', 16, 1);
        END
    END
    ELSE
    BEGIN
        RAISERROR('Email không tồn tại.', 16, 1);
    END

    CLOSE SYMMETRIC KEY AESKey;
END;


CREATE PROCEDURE SP_UPD_ENCRYPT_USER
    @ID NVARCHAR(20),
    @EMAIL NVARCHAR(100),
    @PASSWORD NVARCHAR(100),
    @ROLE NVARCHAR(50),
    @PHONE NVARCHAR(20),
    @FULL_NAME NVARCHAR(100),
    @DEPARTMENT_ID NVARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        OPEN SYMMETRIC KEY AESKey DECRYPTION BY PASSWORD = '05102024';

        DECLARE @EncryptedPassword VARBINARY(MAX);
        DECLARE @EncryptedPhone VARBINARY(MAX);

        SET @EncryptedPassword = EncryptByKey(Key_GUID('AESKey'), @PASSWORD); 
        SET @EncryptedPhone = EncryptByKey(Key_GUID('AESKey'), @PHONE);

        UPDATE [Users]
        SET EMAIL = @EMAIL, PASSWORD = @EncryptedPassword, 
            ROLE = @ROLE, PHONE = @EncryptedPhone, 
            FULL_NAME = @FULL_NAME, department_id = @DEPARTMENT_ID
        WHERE ID = @ID;

        CLOSE SYMMETRIC KEY AESKey;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

CREATE PROCEDURE SP_DEL_ENCRYPT_USER
    @ID NVARCHAR(20)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM [Users] WHERE ID = @ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;

EXEC SP_INS_ENCRYPT_USER 
    @ID = 'admin',
    @EMAIL = 'admin@example.com',
    @PASSWORD = '123',
    @ROLE = 'admin',
    @PHONE = '123456789',
    @FULL_NAME = 'Admin User',
	@DEPARTMENT_ID = 'D1';

EXEC SP_INS_ENCRYPT_USER 
    @ID = 'user',
    @EMAIL = 'user@example.com',
    @PASSWORD = '123',
    @ROLE = 'employee',
    @PHONE = '987654321',
    @FULL_NAME = 'User Employee',
	@DEPARTMENT_ID = 'D1';

	EXEC SP_LOGIN_USER 
    @EMAIL = '	',
    @PASSWORD = '123';

EXEC SP_LOGIN_USER 
    @EMAIL = 'user@example.com',
    @PASSWORD = '123';

