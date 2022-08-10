CHAPTER_NUMBER=$1
WORKING_DIRECTORY='/home/samuel/Documents/labo/scanOP/'

if [ -z $CHAPTER_NUMBER ]
then
    echo 'parameter CHAPTER_NUMBER not found'
    exit 128
fi

rm -r $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER
mkdir $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER

page=1

while [ $page -ge 0 ]
do
    echo
    echo '---------------------------------------------------------------------------------------'
    echo 'Récup code source '$CHAPTER_NUMBER' - '$page

    BRUT_SRC_CODE=$(curl -s https://www.scan-vf.net/one_piece/chapitre-$CHAPTER_NUMBER/$page)
    SRC_CODE=${BRUT_SRC_CODE:180000}
    delimiter='<img class="img-responsive scan-page" src='


    #Delimit img in the source code
    s=$SRC_CODE$delimiter
    array=();

    while [[ $s ]]; do
        array+=( "${s%%"$delimiter"*}" );
        s=${s#*"$delimiter"};
    done;
    IMAGE=${array[1]}

    IFS=' '
    read -ra IMAGE_URL <<< "$IMAGE"
    IMAGE_URL=${IMAGE_URL[1]}
    FILE=$(echo $IMAGE_URL | cut -d '/' -f 9)

    echo 'Vérification de la page :'$page
    if [ -z "$IMAGE_URL" ]; then 
    echo 'Pas de page '$page
    break
    fi

    #We get the file name and now we download it
    echo
    echo 'Récupération de la page '$page '==> '$IMAGE_URL
    echo 'Nom du fichier : '$FILE

    curl $IMAGE_URL -o $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER'/'$FILE

    # if the extension is not good we convert into jpg
    EXTENSION=${FILE: -3}
    if [ $EXTENSION == 'jpg'  ] || [ $EXTENSION == 'png' ]
    then
        echo 'Extension valide : '$EXTENSION
    else
        echo 'Extension invalide -> conversion'
        dwebp $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER'/'$FILE -o $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER'/page-'$page'.jpg'
        rm $WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER'/'$FILE
    fi

    if [[ $page -eq 100 ]]; then
        break
    fi
    ((page++))
    
    echo '---------------------------------------------------------------------------------------'
done

echo 'Téléchargement terminé'
echo 'Chapitre '$CHAPTER_NUMBER' disponible : '$WORKING_DIRECTORY'chapitre-'$CHAPTER_NUMBER

