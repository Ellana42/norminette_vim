import subprocess
import sys

RED   = "\033[1;31m"  
GREEN = "\033[0;32m"
RESET = "\033[0;0m"
output = subprocess.run("norminette", capture_output=True).stdout.decode("utf-8")

if "Error:" in output:
    sys.stdout.write(RED)
    print("Norminette Error")
else:
    sys.stdout.write(GREEN)
    print("Norminette Ok !")
sys.stdout.write(RESET)
