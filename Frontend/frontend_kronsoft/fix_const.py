import subprocess
import re

def fix_constants():
    # Run flutter analyze and capture output
    process = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, cwd='.')
    output = process.stdout + process.stderr

    # Parse output for 'invalid_constant'
    pattern = re.compile(r'error - Invalid constant value - (.+?):(\d+):\d+ - invalid_constant')
    matches = pattern.findall(output)

    # Sort matches by line number in descending order to avoid shifting issues when removing text
    # Wait, if we just remove 'const ' from the line, length changes but line number doesn't.
    files_to_fix = {}
    for file_path, line_num in matches:
        if file_path not in files_to_fix:
            files_to_fix[file_path] = []
        files_to_fix[file_path].append(int(line_num))

    for file_path, line_nums in files_to_fix.items():
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            for line_num in set(line_nums):
                idx = line_num - 1
                if 0 <= idx < len(lines):
                    lines[idx] = lines[idx].replace('const ', '')

            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            print(f'Fixed {len(line_nums)} constants in {file_path}')
        except Exception as e:
            print(f'Error fixing {file_path}: {e}')

if __name__ == '__main__':
    fix_constants()
