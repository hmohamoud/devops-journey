the starting/default permission for a file is 666
the starting/default permission for a file is 777
when you create a file it will apply the starting/default permission - umask
you can change your umask e.g. umask 077
chmod -R 755 ops-lab applies the same permission to every file in it including the directory itself  
archive means putting multiple files/directories into one package
uncompressed means Package them without trying to make the package smaller
e.g. this creates AND archive tar -cvf ops-lab/backups/configs.tar ops-lab/configs this is where the archive will be inside the location ops-lab/backups/configs.tar and we will name the archive configs.tar( SO IT SAY I WANT IT TO BE IN THIS LOCATION AND NAME THE ARCHIVE configs.tar) and ops-lab/configs will be the thing we are archiving 
tar -tvf ops-lab/backups/configs1.tar lets you see what is inside the archive you created.
tar -xvf ops-lab/backups/configs1.tar -C ops-lab/extracts lets me extracts the contents inside the archive into a specific target directory using `-C` and i can choose the directory i created a directory called ops-lab/extracts

compressed means Package them while also making the package smaller
e.g. tar -czvf ops-lab/backups/configs.tar.gz ops-lab/configs this creates an archive but it compresses the archive, reducing its size.


This creates a compressed archive but excludes any txt files inside ops-lab/app.
tar -zcvf ops-lab/testdir/app-structure.tar.gz --exclude="*.txt" ops-lab/app

c = Create 📦
t = Tell me what's inside 👀
x = eXtract 📤

The same as tar -cvf just different format
zip -r ops-lab/backups/configs.zip ops-lab/configs

the same as tar -tvf just different format 
unzip ops-lab/backups/configs.zip -d ops-lab/backups/unizipped-configs

create a sym link:
ln -s ops-lab/app/releases/v1.2.0 ops-lab/app/current
this creates the link called ops-lab/app/current
and it points to ops-lab/app/releases/v1.2.0

2. Confirm the symlink actually works: `cat ops-lab/app/current/app.txt` — should transparently read through to `v1.2.0`'s file. 
this will first go to the target which is ops-lab/app/releases/v1.2.0 then read whats inside inside it 
in other words just think of the target replacing the cat ops-lab/app/current
imagine:
cat ops-lab/app/current/app.txt
this will go to the target
and read app.txt

if you want to repoint the symlink you created to a different target you do 
ls -sfn ops-lab/app/releases/v1.0.0 ops-lab/app/current

when creating symlinks its better to make it absolute then relative (so no errors)
e.g. ls -s "$(pwd)/ops-lab/app/releases/v1.0.0" ops-lab/app/current

readlink -f ops-lab/app/current
tells you what the symlink points basically the target of the symlik


find ops-lab/app/releases -type d -exec chmod 755 {} +
find ops-lab/app/releases → search this directory tree
-type d → applies to only directories inside the directory tree
-exec chmod 755 {} + → apply chmod 755 to everything found

find ops-lab/app/releases -type f -exec chmod 644 {} +
same thing
-type f means applies to only files inside the directory tree