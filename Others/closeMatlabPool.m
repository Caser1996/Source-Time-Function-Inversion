function [] = closeMatlabPool  
   poolobj = gcp('nocreate');  
   delete(poolobj);  
end