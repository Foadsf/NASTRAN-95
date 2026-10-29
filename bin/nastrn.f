      PROGRAM NASTRN        
C        
      CHARACTER*80    VALUE
      CHARACTER*5     TMP
      INTEGER         SPERLK
      REAL            SYSTM(94)
      COMMON / LSTADD / LASTAD
      COMMON / SYSTEM / ISYSTM(94),SPERLK
      COMMON / SOFDSN / SDSN(10)
      COMMON / LOGOUT / LOUT
      COMMON / RESDIC / IRDICT, IROPEN
      COMMON / ZZZZZZ / IZ(14000000)
      COMMON / DBM    / IDBBAS, IDBFRE, IDBDIR, INDBAS, INDCLR, INDCBP
     &,                 NBLOCK, LENALC, IOCODE, IFILEX, NAME,   MAXALC
     &,                 MAXBLK, MAXDSK, IDBLEN, IDBADR, IBASBF, INDDIR
     &,                 NUMOPN, NUMCLS, NUMWRI, NUMREA, LENOPC
      INCLUDE 'NASNAMES.COM'
      CHARACTER*80    SDSN
      EQUIVALENCE    ( ISYSTM, SYSTM )
      LENOPC = 14000000
C        
C     SAVE STARTING CPU TIME AND WALL CLOCK TIME IN /SYSTEM/        
C      
      ISYSTM(18) = 0
      CALL SECOND (SYSTM(18))        
      CALL WALTIM (ISYSTM(32))        
C        
C     EXECUTE NASTRAN SUPER LINK
C        
      LEN = 80
      VALUE = ' '
      CALL NSDEFS
      CALL BTSTRP
      CALL GETENV ( 'DBMEM', VALUE )
      READ ( VALUE, * ) IDBLEN
      CALL GETENV ( 'OCMEM', VALUE )
      READ ( VALUE, * ) IOCMEM
      IF ( IOCMEM .LE. LENOPC ) GO TO 10
      PRINT *,' LARGEST VALUE FOR OPEN CORE ALLOWED IS:',LENOPC
      CALL MESAGE ( -61, 0, 0 )
10    IF ( IDBLEN .NE. 0 ) IDBLEN = LENOPC - IOCMEM 
      LASTAD = LOCFX( IZ( IOCMEM ) )
      IF ( IDBLEN .NE. 0 ) IDBADR = LOCFX( IZ( IOCMEM+1 ) )
      LENOPC = IOCMEM
      CALL DBMINT
      LOUT   = 3
      IRDICT = 4
      SPERLK = 1        
      ISYSTM(11) = 1        
      VALUE = ' '
      CALL GETENV ( 'RFDIR',  RFDIR  )
      VALUE = ' '
      CALL GETENV ( 'DIRCTY', DIRTRY )
      LEN = INDEX( DIRTRY, ' ' ) - 1
      DO 20 I = 1, 90
      IF ( I .LE. 9 ) WRITE ( TMP, 901 ) I
      IF ( I .GT. 9 ) WRITE ( TMP, 902 ) I
901   FORMAT('scr',I1)
902   FORMAT('scr',I2)
      DSNAMES( I ) = DIRTRY(1:LEN)//'/'//TMP
20    CONTINUE
      CALL GETENV ( 'LOGNM', LOG )
      DSNAMES(3) = LOG
      CALL GETENV ( 'OPTPNM', OPTP )
      DSNAMES(7)  = OPTP
      CALL GETENV ( 'NPTPNM', NPTP )
      DSNAMES(8)  = NPTP
      CALL GETENV ( 'FTN11', OUT11 )
      DSNAMES(11) = OUT11
      CALL GETENV ( 'FTN12', IN12 )
      DSNAMES(12) = IN12
      CALL GETENV ( 'FTN13', VALUE )
      DSNAMES(13) = VALUE
      CALL GETENV ( 'FTN14', VALUE )
      DSNAMES(14) = VALUE
      CALL GETENV ( 'FTN15', VALUE )
      DSNAMES(15) = VALUE
      CALL GETENV ( 'FTN16', VALUE )
      DSNAMES(16) = VALUE
      CALL GETENV ( 'FTN17', VALUE )
      DSNAMES(17) = VALUE
      CALL GETENV ( 'FTN18', VALUE )
      DSNAMES(18) = VALUE
      CALL GETENV ( 'FTN19', VALUE )
      DSNAMES(19) = VALUE
      CALL GETENV ( 'FTN20', VALUE )
      DSNAMES(20) = VALUE
      CALL GETENV ( 'FTN21', VALUE )
      DSNAMES(21) = VALUE
      CALL GETENV ( 'PLTNM', PLOT )
      DSNAMES(10) = PLOT
      CALL GETENV ( 'DICTNM', DIC )
      DSNAMES(4) = DIC
      CALL GETENV ( 'PUNCHNM', PUNCH )
      DSNAMES(1) = PUNCH 
      CALL GETENV ( 'SOF1', VALUE )
      SDSN(1) = VALUE
      CALL GETENV ( 'SOF2', VALUE )
      SDSN(2) = VALUE
      CALL GETENV ( 'SOF3', VALUE )
      SDSN(3) = VALUE
      CALL GETENV ( 'SOF4', VALUE )
      SDSN(4) = VALUE
      CALL GETENV ( 'SOF5', VALUE )
      SDSN(5) = VALUE
      CALL GETENV ( 'SOF6', VALUE )
      SDSN(6) = VALUE
      CALL GETENV ( 'SOF7', VALUE )
      SDSN(7) = VALUE
      CALL GETENV ( 'SOF8', VALUE )
      SDSN(8) = VALUE
      CALL GETENV ( 'SOF9', VALUE )
      SDSN(9) = VALUE
      CALL GETENV ( 'SOF10', VALUE )
      SDSN(10) = VALUE
      OPEN (  3, FILE=DSNAMES(3) ,STATUS='UNKNOWN')
      IF ( DSNAMES(11) .NE. 'none' )
     & OPEN ( 11, FILE=DSNAMES(11),STATUS='UNKNOWN')
      IF ( DSNAMES(12) .NE. 'none' )
     & OPEN ( 12, FILE=DSNAMES(12),STATUS='UNKNOWN')
      IF ( DSNAMES(10) .NE. 'none' )
     & OPEN ( 10, FILE=DSNAMES(10),STATUS='UNKNOWN')
      IF ( DSNAMES(4) .NE. 'none' )
     & OPEN ( 4, FILE=DSNAMES(4),STATUS='UNKNOWN')
      IF ( DSNAMES(1) .NE. 'none' )
     & OPEN ( 1, FILE=DSNAMES(1),STATUS='UNKNOWN')
      CALL XSEM00       
      STOP
      END        
      SUBROUTINE NSDEFS
C
C     PORTABLE DEFAULTS FOR THE ENVIRONMENT VARIABLES THAT THE ORIGINAL
C     C-SHELL WRAPPER (BIN/NASTRAN) USED TO SET. A VARIABLE THAT IS ALREADY
C     SET IS NEVER OVERRIDDEN. LETS THE STATIC EXECUTABLE RUN STANDALONE:
C         NASTRAN < DECK.INP > DECK.OUT
C
      CHARACTER*512 V, A
      INTEGER       I, K
      CALL NSDEF1 ( 'DBMEM',   '12000000'    )
      CALL NSDEF1 ( 'OCMEM',   '2000000'     )
      CALL NSDEF1 ( 'DIRCTY',  '.'           )
      CALL NSDEF1 ( 'LOGNM',   'nastran.log' )
      CALL NSDEF1 ( 'OPTPNM',  'none'        )
      CALL NSDEF1 ( 'NPTPNM',  'none'        )
      CALL NSDEF1 ( 'PLTNM',   'none'        )
      CALL NSDEF1 ( 'DICTNM',  'none'        )
      CALL NSDEF1 ( 'PUNCHNM', 'none'        )
      CALL NSDEF1 ( 'FTN11',   'none'        )
      CALL NSDEF1 ( 'FTN12',   'none'        )
      CALL NSDEF1 ( 'FTN13',   'none'        )
      CALL NSDEF1 ( 'FTN14',   'none'        )
      CALL NSDEF1 ( 'FTN15',   'none'        )
      CALL NSDEF1 ( 'FTN16',   'none'        )
      CALL NSDEF1 ( 'FTN17',   'none'        )
      CALL NSDEF1 ( 'FTN18',   'none'        )
      CALL NSDEF1 ( 'FTN19',   'none'        )
      CALL NSDEF1 ( 'FTN20',   'none'        )
      CALL NSDEF1 ( 'FTN21',   'none'        )
      CALL NSDEF1 ( 'SOF1',    'none'        )
      CALL NSDEF1 ( 'SOF2',    'none'        )
      CALL NSDEF1 ( 'SOF3',    'none'        )
      CALL NSDEF1 ( 'SOF4',    'none'        )
      CALL NSDEF1 ( 'SOF5',    'none'        )
      CALL NSDEF1 ( 'SOF6',    'none'        )
      CALL NSDEF1 ( 'SOF7',    'none'        )
      CALL NSDEF1 ( 'SOF8',    'none'        )
      CALL NSDEF1 ( 'SOF9',    'none'        )
      CALL NSDEF1 ( 'SOF10',   'none'        )
C
C     RIGID FORMAT LIBRARY: <DIRECTORY OF THE EXECUTABLE>/RF, ELSE ./RF
C
      V = ' '
      CALL GETENV ( 'RFDIR', V )
      IF ( V .NE. ' ' ) RETURN
      A = ' '
      CALL GET_COMMAND_ARGUMENT ( 0, A )
      K = 0
      DO 10 I = LEN_TRIM( A ), 1, -1
      IF ( A(I:I) .EQ. '/' .OR. A(I:I) .EQ. '\' ) THEN
         K = I
         GO TO 20
      END IF
10    CONTINUE
20    IF ( K .GT. 0 ) THEN
         CALL NSPUTENV ( 'RFDIR='//A(1:K)//'rf' )
      ELSE
         CALL NSPUTENV ( 'RFDIR=rf' )
      END IF
      RETURN
      END
      SUBROUTINE NSDEF1 ( NM, DF )
      CHARACTER*(*) NM, DF
      CHARACTER*512 V
      V = ' '
      CALL GETENV ( NM, V )
      IF ( V .EQ. ' ' ) CALL NSPUTENV ( NM//'='//DF )
      RETURN
      END
