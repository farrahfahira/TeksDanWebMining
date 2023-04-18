import wget

in_count = 1
count = 1
text_file = open("list-tren.txt", "r")
lines = text_file.readlines()

for line in lines:
    wget.download(line, 'crawling_data/tren/' +
                  str(count) + '.html')
    print(int(in_count))

    in_count += 1
    count += 1
    count

text_file.close()
