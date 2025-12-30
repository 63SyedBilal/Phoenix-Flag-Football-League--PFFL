import os
import re

def remove_prints(directory):
    # Regex to match print(...) and debugPrint(...) on a single line or multiline
    # This is a basic regex and might miss some complex cases or catch some it shouldn't, 
    # but for typical print usage it works well.
    # We look for (print|debugPrint) followed by ( and anything until );
    pattern = re.compile(r'^\s*(print|debugPrint)\s*\(.*?\);?\s*$', re.MULTILINE | re.DOTALL)
    
    # Simpler line-by-line version for common cases to avoid re.DOTALL issues if print is huge
    line_pattern = re.compile(r'^\s*(print|debugPrint)\(.*\);.*$')

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Remove line by line first for safety
                    lines = content.splitlines()
                    new_lines = []
                    for line in lines:
                        if not line_pattern.match(line):
                            new_lines.add(line)
                    
                    new_content = "\n".join(new_lines)
                    
                    if new_content != content:
                        with open(path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        print(f"Cleaned: {path}")
                except Exception as e:
                    print(f"Error processing {path}: {e}")

if __name__ == "__main__":
    remove_prints("d:/Phoenix-Flag-Football-League--PFFL/pffl_managment/lib")
