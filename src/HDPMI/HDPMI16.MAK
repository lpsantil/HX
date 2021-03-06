
# nmake makefile, creates the version of HDPMI16.EXE with the
# host stack in extended memory. Since v3.18, this is the "standard".
# tools:
# - JWasm | Masm
# - WLib (Open Watcom) | MS OMF lib (lib16.exe)
# - JWLink (modified WLink v1.8)

!include <..\dirs>

!ifndef DEBUG
DEBUG = 0
!endif

!ifndef MASM
MASM=0
!endif

!if $(DEBUG)
AOPTD=-Zi -D_DEBUG
!endif

NAME  = HDPMI16

SRCMODS = \
!include modules.inc
OBJNAMES = $(SRCMODS:.ASM=.OBJ)
!if $(DEBUG)
OBJMODS = $(OBJNAMES:.\=STD16D\)
!else
OBJMODS = $(OBJNAMES:.\=STD16\)
!endif

!if $(MASM)
ASM = ml.exe
!else
ASM = jwasm.exe
!endif
LINK  = jwlink.exe

AOPT= -nologo -c -Cp -Sg -D?32BIT=0 $(AOPTD) -I$(INC32DIR) -Fl$* -Fo$*
LCMDS1=format DOS file $(OUTD)\$(SRC).obj name $*.EXE lib $(OUTD)\$(NAME).lib op q, map=$*.MAP, stack=0

SRC = hdpmi

DEPS0 = hdpmi.inc external.inc version.inc $(NAME).mak

!if $(DEBUG)
OUTD=STD16D
!else
OUTD=STD16
!endif

.SUFFIXES: .asm .obj

.asm{$(OUTD)}.obj:
	@$(ASM) $(AOPT) $<

ALL: $(OUTD) $(OUTD)\$(NAME).EXE 

$(OBJMODS): $(DEPS0)

$(OUTD):
	@mkdir $(OUTD)

# create the standard version

$(OUTD)\$(NAME).EXE: $(OUTD)\$(SRC).obj $(OUTD)\$(NAME).lib $(NAME).mak 
	$(LINK) @<<
$(LCMDS1)
<<
	@..\..\BIN\SETMZHDR.EXE -q $*.EXE
!if $(DEBUG)==0
	@copy $*.EXE ..\..\Bin\*.* >NUL
!endif

$(OUTD)\$(NAME).lib: $(OBJMODS) $(NAME).mak
	@cd $(OUTD)
	@$(LIB16BIN) $(NAME).lib $(OBJNAMES:.\=+)
	@cd ..

clean:
	@del $(OUTD)\*.obj
	@del $(OUTD)\*.lib
	@del $(OUTD)\*.exe
	@del $(OUTD)\*.map
	@del $(OUTD)\*.lst
