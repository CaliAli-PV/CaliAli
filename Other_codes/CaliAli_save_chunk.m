function CaliAli_save_chunk(filename, Y)
  if exist(filename, 'file') == 2
    m = matfile(filename, 'Writable', true);
    fprintf('Appending to "%s"...\n', filename);
    m.Y = cat(3, m.Y, Y);
  else
    fprintf('Creating "%s"...\n', filename);
    save(filename, 'Y', '-v7.3', '-nocompression');
  end
end