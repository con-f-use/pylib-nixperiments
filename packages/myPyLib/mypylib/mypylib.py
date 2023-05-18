import sys

def cli(args=None):
    args = sys.argv[1:] if args is None else args
    print(f"Hello from mypylib. You arged me with {args}!")
