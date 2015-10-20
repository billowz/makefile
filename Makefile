#############################################################
# Generic Makefile for C+ Program
#
# License: GPL (General Public License)
# Author:  tao.zeng <tao.zeng@digicompass.com>
# Date:    2015/10/18 (version 0.1)
#
# Description:
#
# Usage:
# ------
# 1. Copy the Makefile to your program directory.
# 2. Change Settings for your program.
# 3. make to start building your program.
#
# Make Target:
# ------------
# The Makefile provides the following targets to make:
#   make           compile and link all
#   make show      show variables
#   make clean	   clean objects, the executable and dependencies 
#   make help      get the usage of the makefile
#
# ================Settings===============
#
# SUBDIRS 				=	# Make Directories 
# CFLAGS				=   # Global CFLAGS
# LDFLAGS				=   # Global LDFLAGS
# TYPE					=   # Global Link TYPE(default:exe): exe(executable); shlib(shared lib); stlib(static lib)
# INCLUDES				=   # Global Include Files
# SOURCES				=   # Global Source Files
# BIN_DIR				=   # Global Complie Directory(default:./bin) (*.o;*.d;default directory of program target)
# PROGRAMS				=	# Programs
# $$program_CFLAGS		=   # CFLAGS of $$program
# $$program_LDFLAGS		=   # LDFLAGS of $$program
# $$program_TYPE		=   # Link Type of $$program(default:$(TYPE)): bin(general program); shlib(shared lib); stlib(static lib)
# $$program_INCLUDES	=   # Include Files of $$program
# $$program_SOURCES		=   # Source Files of $$program
# $$program_BIN_DIR		=   # Complie Directory of $$program(default:$(BIN_DIR)) (just for $$program)
# 
# ================End Settings===============
#
#############################################################





# ================init default settings======================
ifndef CC
CC		= gcc
endif
ifndef LD
LD		= ld
endif
ifndef AR
AR		= ar
endif
ifndef RM
RM		= rm -f
endif
ifndef MKDIR
MKDIR	= mkdir -p
endif

ifndef TYPE
TYPE	= exe
endif
ifndef BIN_DIR
BIN_DIR	= ./bin
endif

# ================init default settings end======================

# global objs
OBJS		= $(addprefix $(BIN_DIR)/,$(subst ./,,$(strip $(SOURCES:.c=.o))))

# mk bin dirs
$(foreach dirname,$(sort $(dir $(SOURCES))), $(shell $(MKDIR) $(BIN_DIR)/$(dirname)))

# append path
vpath %.h $(sort $(dir $(INCLUDES)))
vpath %.c $(sort $(dir $(SOURCES)))

INC_FLAGS	= $(addprefix -I ,$(sort $(dir $(INCLUDES))))
#CFLAGS		+= $(addprefix -I ,$(sort $(dir $(INCLUDES))))

define init_program
$1_OBJS		= $(OBJS)
ifdef $1_SOURCES
$1_OBJS		+= $(addprefix $(BIN_DIR)/,$(subst ./,,$(patsubst %.c,%.o,$($1_SOURCES))))
vpath %.c $(sort $(dir $($1_SOURCES)))
$(foreach dirname,$(sort $(dir $($1_SOURCES))), $(shell $(MKDIR) $(BIN_DIR)/$(dirname)))
else
$1_SOURCES	=
endif
ifdef $1_INCLUDES
vpath %.h $(sort $(dir $($1_INCLUDES)))
#$1_CFLAGS	+= $(addprefix -I,$(sort $(dir $($1_INCLUDES))))
$1_INC_FLAGS = $(addprefix -I,$(sort $(dir $($1_INCLUDES))))
else
$1_INCLUDES	=
endif

ifndef $1_BIN_DIR
$1_BIN_DIR	= $(BIN_DIR)
endif
ifndef $1_TYPE
$1_TYPE	= $(TYPE)
endif
endef

PROGRAMS_CLEAN	= 
PROGRAMS_SHOW	= 

define create_program
$1:$($1_OBJS)
	@echo "Building program: $1"
	@echo "Invoking: C Linker"
ifeq ($($1_TYPE),shlib)
	$(CC) -fPIC -shared $(CFLAGS) $($1_CFLAGS) $(LDFLAGS) $($1_LDFLAGS) $(INC_FLAGS) $($1_INC_FLAGS) -o $($1_BIN_DIR)/lib$1.so $($1_OBJS)
else 
ifeq ($($1_TYPE),stlib)
	$(AR) -r $(CFLAGS) $($1_CFLAGS) $(LDFLAGS) $($1_LDFLAGS) $(INC_FLAGS) $($1_INC_FLAGS) -o $($1_BIN_DIR)/lib$1.a $($1_OBJS) 
else 
ifeq ($($1_TYPE),exe)
	$(CC) $(CFLAGS) $($1_CFLAGS) $(LDFLAGS) $($1_LDFLAGS) $(INC_FLAGS) $($1_INC_FLAGS) -o $($1_BIN_DIR)/$1 $($1_OBJS) 
else
	@echo "Invalid $1_TYPE:"$($1_TYPE)
endif
endif
endif
	@echo "Finished build program: $1"
	@echo " "


$1_CLEAN:
	@echo "Clean executable:$1"
	$(RM) $($1_BIN_DIR)/$1 $($1_BIN_DIR)/$1.exe
PROGRAMS_CLEAN	+= $1_CLEAN

$1_SHOW:
	@echo "$1 Variables:"
	@echo "  TYPE       = $($1)"
	@echo "  INCLUDES   = "$($1_INCLUDES)
	@echo "  SOURCES    = "$($1_SOURCES)
	@echo "  CFLAGS     = "$($1_CFLAGS)
	@echo "  INC_FLAGS  = "$($1_INC_FLAGS)
	@echo "  LDFLAGS    = "$($1_LDFLAGS)
	@echo "  BIN_DIR    = "$($1_BIN_DIR)
PROGRAMS_SHOW	+= $1_SHOW	
endef

# init programes
$(foreach program,$(PROGRAMS),$(eval $(call init_program,$(program))))

all : $(SUBDIRS) $(PROGRAMS)

$(BIN_DIR)/%.o: %.c
	@echo "Building file: $< -> $@"
	@echo "Invoking: C Compiler"
	$(CC) $(CFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o $@ -c $<
	@echo "Finished building: $< -> $@"
	@echo " "

# init programes Target
$(foreach program,$(PROGRAMS),$(eval $(call create_program,$(program))))

$(SUBDIRS):
	@echo "Making subdir $@"
	$(MAKE) -C $@

CLEAN:
	@echo "Making Clean"
	
clean: CLEAN $(PROGRAMS_CLEAN)
	@echo "Clean objects"
	$(RM) $(BIN_DIR)/*.o $(BIN_DIR)/**/*.o
	@echo "Clean dependencies" 
	$(RM) $(BIN_DIR)/*.d $(BIN_DIR)/**/*.d
	@list="$(SUBDIRS)"; for subdir in $$list; do \
		echo "Clean in $$subdir";\
		$(MAKE) -C $$subdir clean;\
	done
	@echo "Finished Make clean"

SHOW:
	@echo "Global Variables:"
	@echo "SUBDIRS     = $(SUBDIRS)"
	@echo "BIN_DIR     = $(BIN_DIR)"
	@echo "CFLAGS      = $(CFLAGS)"
	@echo "LDFLAGS     = $(LDFLAGS)"
	@echo "INC_FLAGS   = $(INC_FLAGS)"
	@echo "TYPE        = $(TYPE)"
	@echo "INCLUDES    = $(INCLUDES)"
	@echo "SOURCES     = $(SOURCES)"
	@echo "PROGRAMS    = $(PROGRAMS)"
	
show: SHOW $(PROGRAMS_SHOW)
		
help:
	@echo "Generic Makefile for C Programs"
	@echo
	@echo "Usage: make [TARGET]"
	@echo "TARGETS:"
	@echo "  all   (=make) compile and link."
	@for program in $(PROGRAMS); do \
		echo "  $$program  compile and link $$program"; \
	done
	@for subdir in $(SUBDIRS); do \
		echo "  $$subdir  make subdir $$subdir";\
	done
	@echo "  clean clean objects and the executable file."
	@echo "  show  show variables (for debug use only)."
	@echo "  help  print this message."
	@echo
	
.PHONY: all clean show help $(SUBDIRS)