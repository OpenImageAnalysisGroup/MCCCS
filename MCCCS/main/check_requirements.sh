SOURCE="${BASH_SOURCE[0]}"
SOURCE="$(cd "$(dirname "$0")" && pwd -P)"
case $SOURCE in  
     *\ * )
		   echo "Problematic script location: $SOURCE"
		   echo
		   echo "Currently, the MCCCS system needs to be placed and saved in"
		   echo "a directory structure without any SPACE character in the name."
		   echo
		   echo "Script execution needs to be stopped - EXIT 1"
	   exit 1
          ;;
       *)
          ;;
esac
#check required commands
MISSING="The following command(s) cannot be found on your system: "
ISMISSING=false
#wget
command -v wget >/dev/null 2>&1 || { MISSING="$MISSING wget "; ISMISSING=true; }
#unzip
command -v unzip >/dev/null 2>&1 || { MISSING="$MISSING unzip "; ISMISSING=true; }
#bc
command -v bc >/dev/null 2>&1 || { MISSING="$MISSING bc "; ISMISSING=true; }
#xargs
command -v xargs >/dev/null 2>&1 || { MISSING="$MISSING xargs "; ISMISSING=true; }
#java
command -v java >/dev/null 2>&1 || { MISSING="$MISSING java "; ISMISSING=true; }
#check
if [[ "$ISMISSING" == true ]];
then
	printf "$MISSING\nPlease install the missing commands, further informations can be found in the documentation: http://mcccs.sourceforge.net/files/MCCCS_documentation_v1.pdf\n"
	exit 1;
fi
