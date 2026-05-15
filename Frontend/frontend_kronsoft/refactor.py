import os
import re
import subprocess

def process_directory(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'AppColors' not in content:
        return

    # Replace const keywords that might wrap context.appColors
    # This is a brute force approach: we just remove const from things that might contain AppColors
    # A better way is to iteratively remove const where the compiler complains, 
    # but for a script, we'll remove const from lines containing AppColors
    
    lines = content.split('\n')
    for i in range(len(lines)):
        if 'AppColors' in lines[i]:
            lines[i] = lines[i].replace('const ', '')
            # also look up to 2 lines above for 'const '
            for j in range(max(0, i-2), i):
                if 'const ' in lines[j] and ('Text(' in lines[j] or 'TextStyle(' in lines[j] or 'Icon(' in lines[j] or 'BorderSide(' in lines[j] or 'BoxDecoration(' in lines[j]):
                    lines[j] = lines[j].replace('const ', '')
                    
    content = '\n'.join(lines)
    
    # Finally, replace AppColors. with context.appColors.
    content = re.sub(r'AppColors\.([a-zA-Z0-9_]+)', r'context.appColors.\1', content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    process_directory('lib')
