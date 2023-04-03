import requests
from bs4 import BeautifulSoup

awal_tanggal = 1
awal_bulan = 3
akhir_tanggal = 31
akhir_bulan = 3
session = requests.session()

hitung = 0  # tambahkan variabel hitung

while awal_tanggal <= akhir_tanggal or awal_bulan <= akhir_bulan:
    html = 'https://indeks.kompas.com/?site=tren&date=2023-' + \
        str(awal_bulan) + '-' + str(awal_tanggal)
    req = session.get(html)
    bs = BeautifulSoup(req.text, 'html.parser')

    link = bs.find_all('a', attrs={'class': 'article__link'})

    for links in link:
        f = open("list-trenkompas.txt", "a")

        hitung += 1

        if hitung >= 506:  # tambahkan kondisi untuk keluar dari loop while
            break

        f.write(links['href'] + "\n")

    if awal_tanggal == 22 and awal_bulan == 2:
        break
    elif awal_tanggal == 31:
        awal_tanggal = 1
        awal_bulan += 1
    else:
        awal_tanggal += 1


f.close()
