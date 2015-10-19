# ================User Settings======================
DEBUG			= yes
SUBDIRS			=
# globals settings
CFLAGS			= -Wall -O2 -mavx
LDFLAGS			= 
# shlib/stlib/bin
TYPE			= bin
INCLUDES		= inc/test2.h
SOURCES			= src/test2.c 
BIN_DIR			= ./bin

# programes
PROGRAMS		= test cmph

# programe settings
cmph_SOURCES	= src/cmph.c
cmph_CFLAGS		=
cmph_LDFLAGS	= -lcmph -Wl,-rpath=/usr/local/lib
cmph_TYPE		= bin

test_SOURCES	= src/test.c 
test_INCLUDES	= inc/test.h 
test_CFLAGS		= 
test_LDFLAGS	=
test_TYPE		= bin
# ================End User Settings======================

# ================Directives======================
CC			= gcc
LD			= ld
AR			= ar
RM			= rm -f
MKDIR		= mkdir -p
SHELL   	= /bin/sh
# ================End Directives======================

# global objs
OBJS		= $(addprefix $(BIN_DIR)/,$(subst ./,,$(strip $(SOURCES:.c=.o))))

# mk bin dirs
$(foreach dirname,$(sort $(dir $(SOURCES))), $(shell $(MKDIR) $(BIN_DIR)/$(dirname)))

# append path
vpath %.h $(sort $(dir $(INCLUDES)))
vpath %.c $(sort $(dir $(SOURCES)))

define init_program
$1_OBJS		= $(addprefix $(BIN_DIR)/,$(subst ./,,$(patsubst %.c,%.o,$($1_SOURCES))))
$1_OBJS		+= $(OBJS)

# append path
vpath %.h $(sort $(dir $($1_INCLUDES)))
vpath %.c $(sort $(dir $($1_SOURCES)))

ifndef $($1_TYPE)
$($1_TYPE)	= $(TYPE)
endif
endef


define create_program
$1:$($1_OBJS)
	@echo 'Building target: $1'
	@echo 'Invoking: C Linker'
ifeq ($($1_TYPE),shlib)
	$(CC) -fPIC -shared $($1_CFLAGS) $($1_LDFLAGS) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/lib$1.so $($1_OBJS)
else 
ifeq ($($1_TYPE),stlib)
	$(AR) -r $($1_CFLAGS) $($1_LDFLAGS) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/lib$1.a $($1_OBJS) 
else 
ifeq ($($1_TYPE),bin)
	$(CC) $($1_CFLAGS) $($1_LDFLAGS) $(CFLAGS) $(LDFLAGS) -o $(BIN_DIR)/$1 $($1_OBJS) 
else
	@echo 'Invalid $1_TYPE:'$($1_TYPE)
endif
endif
endif
	@echo 'Finished building target: $1'
	@echo ' '
endef

# init programes
$(foreach program,$(PROGRAMS),$(eval $(call init_program,$(program))))

all : $(PROGRAMS)

$(BIN_DIR)/%.o: %.c
	@echo 'Building file: $< -> $@'
	@echo 'Invoking: C Compiler'
	$(CC) $(CFLAGS) $(FLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o $@ -c $<
	@echo 'Finished building: $< -> $@'
	@echo ' '

# init programes Target
$(foreach program,$(PROGRAMS),$(eval $(call create_program,$(program))))

clean:
	$(RM) $(addprefix $(BIN_DIR)/, $(PROGRAMS))
	$(RM) $(addprefix $(BIN_DIR)/, $(patsubst %,%.exe,$(PROGRAMS)))
	$(RM) $(BIN_DIR)/**/*.o 
	$(RM) $(BIN_DIR)/**/*.d
	
show:
	@echo 'SUBDIRS         = '$(SUBDIRS)
	@echo 'BIN_DIR         = '$(BIN_DIR)
	@echo 'CFLAGS          = '$(CFLAGS)
	@echo 'LDFLAGS         = '$(LDFLAGS)
	@echo 'TYPE            = '$(TYPE)
	@echo 'INCLUDES        = '$(INCLUDES)
	@echo 'SOURCES         = '$(SOURCES)
	@echo 'PROGRAMS        = '$(PROGRAMS)
	@$(foreach program,$(PROGRAMS),echo $(program);echo $(program_INCLUDES);)
	@for program in $(PROGRAMS); do echo $$program'_INCLUDES = ' $($$program_INCLUDES); done
	

help:
	@echo 'Generic Makefile for C Programs'
	@echo
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all   (=make) compile and link.'
	@for program in $(PROGRAMS); do echo '  '$$program'  :compile and link '$$program; done
	@echo '  clean clean objects and the executable file.'
	@echo '  show  show variables (for debug use only).'
	@echo '  help  print this message.'
	@echo