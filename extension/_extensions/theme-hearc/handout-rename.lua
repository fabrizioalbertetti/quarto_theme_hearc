-- Script post-render : renomme « cours+handout.pdf » en « cours-handout.pdf ».
-- Quarto suffixe le PDF avec le nom de la variante de format (+handout) ;
-- ce suffixe n'est pas configurable, d'où le renommage après coup.
-- Les chemins de QUARTO_PROJECT_OUTPUT_FILES sont relatifs à la racine du
-- projet, qui est le répertoire courant lors de l'exécution du script.

local files = os.getenv("QUARTO_PROJECT_OUTPUT_FILES")
local list_file = os.getenv("QUARTO_USE_FILE_FOR_PROJECT_OUTPUT_FILES")
if not files and list_file then
  local f = io.open(list_file, "r")
  if f then
    files = f:read("a")
    f:close()
  end
end

for file in (files or ""):gmatch("[^\r\n]+") do
  local target, n = file:gsub("%+handout%.pdf$", "-handout.pdf")
  if n > 0 then
    os.remove(target)  -- os.rename échoue sous Windows si la cible existe
    local ok, err = os.rename(file, target)
    if not ok then
      io.stderr:write("handout-rename : " .. tostring(err) .. "\n")
    end
  end
end
