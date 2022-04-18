import argparse
import asyncio

from .commands.generate_service_token import generate_service_token

parser = argparse.ArgumentParser(description="CLI for authorizer")
parser.add_argument("-c", "--command", help="command to run", required=True)
parser.add_argument(
    "-u", "--user", help="user id to user with commands that require it"
)
args = parser.parse_args()

VALID_COMMANDS = ["service_token"]

if __name__ == "__main__":

    if args.command == "service_token":
        user_id = args.user
        if not user_id:
            print("'service_token' command requires arg 'user', please enter user id")
            exit(0)
        loop = asyncio.get_event_loop()
        loop.run_until_complete(generate_service_token(user_id))
        loop.close()
    elif args.command not in VALID_COMMANDS:
        print(f"Command not in list of valid commands: '{VALID_COMMANDS}'")
