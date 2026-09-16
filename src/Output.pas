unit Output;

  interface

  procedure DisplayHelp;

  implementation

  procedure DisplayHelp;
  begin
    writeln('Bash As Dos Shell');
    writeln('');
    writeln('USAGE:');
    writeln('  bads compile <input_file> [output_folder]');
    writeln('  bads <input_file>');
    writeln('');
    writeln('COMMANDS:');
    writeln('  compile    compile .sh file to .bat file');
    writeln('');
    writeln('OPTIONS:');
    writeln('  -h, --help    Show this help message and exit');
  end;
end.