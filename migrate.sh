set -e

# Example of a script call:
# sudo sh migrate.sh -s FE-B-S**** -g Artur-B-G**** -r CJVT

while getopts s:g:r: flag
do
    case "${flag}" in
        s) snemalec=${OPTARG};;
        g) govorec=${OPTARG};;
        r) remote_name=${OPTARG};;
    esac
done

echo $'\nUstvari mape na Arturju, če te še ne obstajajo'
mkdir -p /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki
mkdir -p /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec/
mkdir -p /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/$govorec
mkdir -p /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/
mkdir -p /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki-bkp/$snemalec/

# Ukazi povezani s kopiranjem posnetkov na Arturju iz mape izvorni-bkp v mape odobreni, zavrnjeni in odobreni-bkp
echo $'\nKopiraj datoteko xlsx z označenimi zavrnjenimi posnetki v mapo Artur:zavrnjeni'
rsync -avi --stats $govorec'_zavrnjeni.xlsx' /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki
echo $'\nOdstrani morebitne predhodne posnetke iz mape Artur:zavrnjeni'
rm -f /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec/*.wav
echo $'\nKopiraj zavrnjene posnetke iz Artur:izvorni-bkp v Artur:zavrnjeni'
rsync -avi --stats --files-from=$govorec'_zavrnjeni.txt' /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/$govorec/ /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec/
echo $'\nOdstrani morebitne predhodne posnetke iz mape Artur:odobreni'
rm -f /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec/*.wav
echo $'\nKopiraj odobrene posnetke iz Artur:izvorni-bkp v Artur:odobreni'
rsync -avi --stats --exclude-from=$govorec'_zavrnjeni.txt' /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/$govorec/*.wav /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec/ 
echo $'\nOdstrani morebitne predhodne posnetke iz mape Artur:odobreni-bkp'
rm -f /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki-bkp/$snemalec/$govorec/*.wav
echo $'\nKopiranje iz Artur:odobreni v Artur:odobreni-bkp'
rsync -avi --stats /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec/*.wav /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki-bkp/$snemalec/$govorec/

# Ukazi povezani z migracijo odobrenih in zavrnjenih posnetkov iz Arturja na nas.cjvt.si
echo $'\nUstvari mapo CJVT:odobreni, če ta še ne obstaja'
rclone mkdir $remote_name:ASR/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec
echo $'\nUstvari mapo CJVT:zavrnjeni, če ta še ne obstaja'
rclone mkdir $remote_name:ASR/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec
echo $'\nKopiraj datoteko xlsx iz Artur:zavrnjeni v CJVT:zavrnjeni'
rclone copy -v /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec'_zavrnjeni.xlsx' $remote_name:ASR/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/
echo $'\nSinhroniziraj mapi Artur:zavrnjeni in CJVT:zavrnjeni'
rclone sync -v --update --ignore-existing /storage/rsdo/cjvt/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec $remote_name:ASR/BraniGovor/BraniGovor-04-FE-IzvorniPosnetki-bkp/$snemalec/ZavrnjeniPosnetki/$govorec
echo $'\nSinhroniziraj mapi Artur:odobreni in CJVT:odobreni'
rclone sync -v --update --ignore-existing /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec $remote_name:ASR/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki/$snemalec/$govorec
echo $'\nSinhroniziraj mapi Artur:odobreni-bkp in CJVT:odobreni-bkp'
rclone sync -v --update --ignore-existing /storage/rsdo/cjvt/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki-bkp/$snemalec/$govorec $remote_name:ASR/BraniGovor/BraniGovor-05-FE-OdobreniPosnetki-bkp/$snemalec/$govorec
