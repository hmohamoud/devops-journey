wc -l < ops-lab/logs/app.log
head -1 ops-lab/logs/app.log
tail -1 ops-lab/logs/app.log
grep "ERROR" ops-lab/logs/app.log | wc -l or grep -c "ERROR" ops-lab/logs/app.log
grep -i "ERROR" ops-lab/logs/app.log | wc -l or grep -ic "ERROR" ops-lab/logs/app.log
one of them is sensitive one of them is case insensitive
grep -i "ERROR" ops-lab/logs/app.log | awk '$2 < "10:04"'
grep -i "ERROR" ops-lab/logs/app.log | awk '$2 > "10:04"'
grep -i "error" ops-lab/logs/app.log | sort | uniq
-----

grep -i "error" ops-lab/logs/app.log | sort | uniq -c | sort -nr | head -1
grep -i "error" ops-lab/logs/app.log | sort | uniq -c | sort -nr | head -3
grep -i "payment" ops-lab/logs/app.log    
grep -i "error" ops-lab/logs/app.log | tail -1 ops-lab/logs/app.log
grep -i "ERROR" ops-lab/logs/app.log | awk '$2 > "10:04"'
-----
wc -l < ops-lab/logs/nginx.log
awk '{print $9}' ops-lab/logs/nginx.log | sort | uniq -c            
awk '{print $1}' ops-lab/logs/nginx.log | sort | uniq -c | sort -nr | head -1
grep -i "503" ops-lab/logs/nginx.log | awk '{print $7}' | sort | uniq -c | sort -nr | head -1
grep -i "503" ops-lab/logs/nginx.log | awk '{print $4}' | head -1     
grep -i "payment" ops-lab/logs/nginx.log | awk '{print $1}' | sort | uniq
awk '$9 == 503 && $7 == "/api/payments"' ops-lab/logs/nginx.log
awk '$9 == 503 && $7 == "/api/payments"' ops-lab/logs/nginx.log
awk '{print $1}' ops-lab/logs/nginx.log | sort | uniq | wc -l 

------

sed '/^$/d; /^#/d' ops-lab/configs/app.conf 
sed '/^$/d; /^#/d' ops-lab/configs/app.conf | cut -d= -f1 
sed '/^$/d; /^#/d' ops-lab/configs/app.conf | cut -d= -f2
grep -iE "WORKERS|TIMEONT|CONNECTIONS|POOL" ops-lab/configs/app.conf 
grep -iE "password|changeme|secret|default" ops-lab/configs/database.conf

-----
Preview without saving:
```bash
sed 's/WORKERS=2/WORKERS=8/g' ops-lab/configs/app.conf
```
Confirm original file was not changed:
```bash
grep -i "workers" ops-lab/configs/app.conf   
```
 
Make change with backup:
```bash
cp ops-lab/configs/app.conf ops-lab/configs/app.bak
```

Verify the change:
```bash
grep "WORKERS" ops-lab/configs/app.conf
```

Verify backup has original:
```bash
grep "WORKERS" ops-lab/configs/app.conf.bak
```

Change PAYMENT_TIMEOUT with backup:
```bash
sed -i.bak 's/PAYMENT_TIMEOUT=30/PAYMENT_TIMEOUT=60/g' ops-lab/configs/app.conf
```

Change both values in database.conf in one command:
```bash
sed -i.bak 's/MAX_POOL_SIZE=10/MAX_POOL_SIZE=50/g; s/IDLE_TIMEOUT=300/IDLE_TIMEOUT=600/g' ops-lab/configs/database.conf
```

Save clean version:
```bash
sed '/^#/d; /^$/d' ops-lab/configs/app.conf > ops-lab/output/clean-app.conf
```

-----
Watch live errors only:
```bash
tail -f ops-lab/logs/app.log | grep -i "error"
```

Append lines from second terminal:
```bash
echo "2026-06-01 10:12:01 INFO Health check passed" >> ops-lab/logs/app.log
echo "2026-06-01 10:12:10 INFO Cache cleared" >> ops-lab/logs/app.log
echo "2026-06-01 10:12:20 INFO Scheduled job completed" >> ops-lab/logs/app.log
echo "2026-06-01 10:12:30 ERROR Payment gateway timeout" >> ops-lab/logs/app.log
echo "2026-06-01 10:12:40 ERROR Database connection failed" >> ops-lab/logs/app.log
```

Watch and save simultaneously:
```bash
tail -f ops-lab/logs/app.log | grep --line-buffered -i "error" | tee -a ops-lab/output/live-errors.log
```

-----
wc -l < ops-lab/data/users.txt 
sort ops-lab/data/users.txt | uniq | wc -l 
sort ops-lab/data/users.txt | uniq -c | sort -nr | head -1
sort ops-lab/data/users.txt | uniq > ops-lab/output/clean-users.txt
wc -l < ops-lab/data/transactions.txt
sort -nr ops-lab/data/transactions.txt | head -1
sort ops-lab/data/transactions.txt | head -1
sort ops-lab/data/transactions.txt | uniq -c | sort -nr | head -1
sort ops-lab/data/transactions.txt | uniq -c | sort -nr   
-----
Every log file:
```bash
find ops-lab/ -name "*.log"
```

Every config file:
```bash
find ops-lab/ -name "*.conf"
```

Biggest files sorted by size:
```bash
find ops-lab/ -type f | xargs du -sh | sort -rh
```

Modified in last 24 hours:
```bash
find ops-lab/ -mtime -1
```

Older than 30 days:
```bash
find ops-lab/ -mtime +30
```

Files with 777 permissions:
```bash
find ops-lab/ -perm 777
```

All shell scripts:
```bash
find ops-lab/ -name "*.sh"
```
