#!/bin/zsh

NAME=$1

echo "CC =\t/usr/bin/clang" > Makefile
echo "RM =\t/bin/rm" >> Makefile
echo "MAKE =\t/usr/bin/make" >> Makefile
echo "MKDIR =\t/bin/mkdir" >> Makefile
echo "" >> Makefile
echo "NAME =" $NAME >> Makefile
echo "" >> Makefile
echo "ROOT =\t\t\$(shell /bin/pwd)" >> Makefile
echo "OPATH =\t\t\$(ROOT)/objs" >> Makefile
echo "CPATH =\t\t\$(ROOT)/srcs" >> Makefile
echo "HPATH =\t\t\$(ROOT)/includes" >> Makefile
echo "LIBPATH =\t\$(ROOT)/libft" >> Makefile
echo "LIBHPATH =\t\$(LIBPATH)/includes" >> Makefile
echo "" >> Makefile
echo "CFLAGS = -O3 -Wall -Werror -Wextra -I \$(HPATH) -I \$(LIBHPATH)" >> Makefile
echo "LIBS = -L \$(LIBPATH) -lft" >> Makefile
echo "" >> Makefile
SRCS=$(ls srcs | grep "\.c" | grep -v "\~")
SRC="SRC = "
for FILE in $SRCS
do
    if [[ -z $FIRST ]]
    then
        SRC="$SRC$FILE"
        FIRST="done"
    else
        SRC="$SRC ;\n\t$FILE"
    fi
done
echo "$SRC" | sed 's/;/\\/g'>> Makefile
echo "" >> Makefile
echo "OFILES = \$(patsubst %.c, \$(OPATH)/%.o, \$(SRC))" >> Makefile
echo "" >> Makefile
echo ".PHONY: all clean fclean re lib.fclean" >> Makefile
echo "" >> Makefile
echo "all: \$(OPATH) \$(NAME)" >> Makefile
echo "" >> Makefile
echo "\$(NAME): \$(OFILES)" >> Makefile
echo "\t@echo \"\$(NAME) : Building Libft\"" >> Makefile
echo "\t@\$(MAKE) -C \$(LIBPATH)" >> Makefile
echo "\t@echo \"\$(NAME) : Building \$@\"" >> Makefile
echo "\t@\$(CC) \$(CFLAGS) -o \$@ \$^ \$(LIBS)" >> Makefile
echo "\t@echo \"\\\033[32mDone !\\\033[0m\"" >> Makefile
echo "" >> Makefile
echo "\$(OPATH)/%.o: \$(CPATH)/%.c" >> Makefile
echo "\t@echo \"\$(NAME) : Creating file \$@\"" >> Makefile
echo "\t@\$(CC) \$(CFLAGS) -c $< -o \$@" >> Makefile
echo "" >> Makefile
echo "\$(OPATH):" >> Makefile
echo "\t@echo \"\$(NAME) : Creating objs directory\"" >> Makefile
echo "\t@\$(MKDIR) \$@" >> Makefile
echo "" >> Makefile
echo "clean:" >> Makefile
echo "\t@echo \"\$(NAME) : Deleting objs\"" >> Makefile
echo "\t@\$(RM) -rf \$(OPATH)" >> Makefile
echo "" >> Makefile
echo "fclean: clean lib.fclean" >> Makefile
echo "\t@echo \"\$(NAME) : Deleting \$(NAME)\"" >> Makefile
echo "\t@\$(RM) -f \$(NAME)" >> Makefile
echo "\t@echo \"\\\033[32mDone !\\\033[0m\"" >> Makefile
echo "" >> Makefile
echo "lib.fclean:" >> Makefile
echo "\t@\$(MAKE) fclean -C \$(LIBPATH)" >> Makefile
echo "" >> Makefile
echo "re: fclean all" >> Makefile
