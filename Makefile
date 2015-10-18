
# ================user settings======================

#Type main/shared-lib/static-lib
TYPE		= main

# program/lib name
PROGRAM		= test
# enable debug
DEBUG		= yes
FLAGS		= -O3
CFLAGS		=
LDFLAGS    	= -lcmph -Wl,-rpath=/usr/local/lib
INC_DIR		= ./inc
SRC_DIR		= ./src
DEBUG_DIR	= ./debug
RELEASE_DIR	= ./release

# ================End user settings======================


# directives
CC			= gcc
LD			= ld
AR			= ar
RM			= rm -rf
MKDIR		= mkdir -p
SHELL   	= /bin/sh

# init sources
ifeq ($(DEBUG),yes)
	BIN_DIR = $(DEBUG_DIR)
else
	BIN_DIR = $(RELEASE_DIR)
endif

SRC_CS		= ${wildcard $(patsubst %,%/*.c,$(SRC_DIR))}
SRC_INCS	= ${wildcard $(patsubst %,%/*.h,$(INC_DIR))}
OBJS		= $(addprefix $(BIN_DIR)/,$(subst ./,,$(strip $(SRC_CS:.c=.o))))
DEPS		= $(strip $(OBJS:.o=.d))

CFLAGS		+= -Wall $(if $(DEBUG),-g,)
CFLAGS		+= $(addprefix -I,$(sort $(dir $(SRC_INCS))))

$(foreach dirname,$(sort $(dir $(SRC_CS))), $(shell $(MKDIR) $(BIN_DIR)/$(dirname)))

vpath %.h $(sort $(dir $(SRC_INCS)))
vpath %.c $(sort $(dir $(SRC_CS)))

# rules to generate objects file
$(BIN_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $(FLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o $@ -c $<
        
$(PROGRAM):$(OBJS)
ifeq ($(TYPE),shared_lib)
	$(CC) -fPIC -shared $(LDFLAGS) $(FLAGS) -o $(BIN_DIR)/lib$(PROGRAM).so $(OBJS) 
else 
ifeq ($(TYPE),static_lib)
	$(AR) -r $(LDFLAGS) -o $(BIN_DIR)/lib$(PROGRAM).a $(OBJS) 
else 
ifeq ($(TYPE),main)
	$(CC) $(LDFLAGS) $(FLAGS) -o $(BIN_DIR)/$(PROGRAM) $(OBJS) 
else
	@echo 'Invalid TYPE:'$(TYPE)
endif
endif
endif


all:$(PROGRAM)

objs:$(OBJS)

clean:
	$(RM) $(BIN_DIR)
	
show:
	@echo 'PROGRAM :'$(PROGRAM)
	@echo 'CFLAGS  :'$(CFLAGS)
	@echo 'DEBUG   :'$(if $(DEBUG),$(DEBUG),'no')
	@echo 'BIN_DIR :'$(BIN_DIR)
	@echo 'SRC_CS  :'$(SRC_CS)
	@echo 'SRC_INCS  :'$(SRC_INCS)
	@echo 'OBJS    :'$(OBJS)
	@echo 'DEPS    :'$(DEPS)
	@echo 'TYPE    :'$(TYPE)
help:
	@echo 'Generic Makefile for C Programs'
	@echo
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all       (=make) compile and link.'
	@echo '  objs      compile only (no linking).'
	@echo '  clean     clean objects and the executable file.'
	@echo '  show      show variables (for debug use only).'
	@echo '  help      print this message.'
	@echo