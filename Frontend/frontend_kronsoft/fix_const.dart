import 'dart:io';

void main() async {
  final result = await Process.run('flutter', ['analyze'], runInShell: true);
  final output = result.stdout.toString() + result.stderr.toString();
  
  final regex = RegExp(r'error - Invalid constant value - (.+?):(\d+):\d+ - invalid_constant');
  final matches = regex.allMatches(output);
  
  final filesToFix = <String, List<int>>{};
  
  for (final match in matches) {
    final filePath = match.group(1)!;
    final lineNum = int.parse(match.group(2)!);
    
    if (!filesToFix.containsKey(filePath)) {
      filesToFix[filePath] = [];
    }
    filesToFix[filePath]!.add(lineNum);
  }
  
  for (final entry in filesToFix.entries) {
    final file = File(entry.key);
    if (!await file.exists()) continue;
    
    final lines = await file.readAsLines();
    final uniqueLines = entry.value.toSet();
    
    for (final lineNum in uniqueLines) {
      final idx = lineNum - 1;
      if (idx >= 0 && idx < lines.length) {
        lines[idx] = lines[idx].replaceFirst('const ', '');
      }
    }
    
    await file.writeAsString(lines.join('\n'));
    print('Fixed ${uniqueLines.length} constants in ${entry.key}');
  }
}
