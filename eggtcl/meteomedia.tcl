## french canadian weather script
## with data from meteomedia.com
## by leprechau@EFnet
## initial version...no help or support
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::meteomedia {
	
	## get my http package from
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	package require lephttp

	## initialize custom channel flag
	setudef flag nometeo

	## setup our location database (current as of 06/25/2006)
	variable locids; array set locids {
		Faizabad,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0007.htm
		Farah,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0006.htm
		Ghurian,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0001.htm
		Herat,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0002.htm
		Jabul-Saraj,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0009.htm
		Jalalabad,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0008.htm
		Kabul,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0003.htm
		Kandahar,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0004.htm
		Mazar-e-Sharif,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0010.htm
		Shebirgan,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0012.htm
		Zaranj,,Afghanistan /Meteo/Villes/intl/Pages/AFXX0014.htm
		{Durban,,Afrique du Sud} /Meteo/Villes/intl/Pages/SFXX0011.htm
		{Johannesburg,,Afrique du Sud} /Meteo/Villes/intl/Pages/SFXX0023.htm
		{Le Cap,,Afrique du Sud} /Meteo/Villes/intl/Pages/SFXX0010.htm
		{Pretoria,,Afrique du Sud} /Meteo/Villes/intl/Pages/SFXX0044.htm
		Tirane,,Albanie /Meteo/Villes/intl/Pages/ALXX0002.htm
		Alger,,Algérie /Meteo/Villes/intl/Pages/AGXX0001.htm
		Oran,,Algérie /Meteo/Villes/intl/Pages/AGXX0006.htm
		Berlin,,Allemagne /Meteo/Villes/intl/Pages/GMXX0007.htm
		Breme,,Allemagne /Meteo/Villes/intl/Pages/DEXX0005.htm
		Cologne,,Allemagne /Meteo/Villes/intl/Pages/DEXX0002.htm
		Dortmund,,Allemagne /Meteo/Villes/intl/Pages/DEXX0004.htm
		Dusseldorf,,Allemagne /Meteo/Villes/intl/Pages/GMXX0028.htm
		Essen,,Allemagne /Meteo/Villes/intl/Pages/DEXX0003.htm
		Francfort,,Allemagne /Meteo/Villes/intl/Pages/DEXX0001.htm
		{Frankfurt am Main,,Allemagne} /Meteo/Villes/intl/Pages/GMXX0040.htm
		Hambourg,,Allemagne /Meteo/Villes/intl/Pages/GMXX0049.htm
		Hannover,,Allemagne /Meteo/Villes/intl/Pages/GMXX0051.htm
		Hanovre,,Allemagne /Meteo/Villes/intl/Pages/DEXX0006.htm
		Munich,,Allemagne /Meteo/Villes/intl/Pages/GMXX0087.htm
		Stuttgart,,Allemagne /Meteo/Villes/intl/Pages/GMXX0128.htm
		Luanda,,Angola /Meteo/Villes/intl/Pages/AOXX0008.htm
		{The Valley,,Anguilla} /Meteo/Villes/intl/Pages/AIXX0001.htm
		Codrington,,Antigua-et-Barbuda /Meteo/Villes/intl/Pages/ACXX0001.htm
		Saint-John's,,Antigua-et-Barbuda /Meteo/Villes/intl/Pages/AGXX0041.htm
		{Aruba,,Antilles Néerlandaises} /Meteo/Villes/intl/Pages/ANXX0003.htm
		{Curaçao,,Antilles Néerlandaises} /Meteo/Villes/intl/Pages/VEXX0039.htm
		{Saint-Maarten,,Antilles Néerlandaises} /Meteo/Villes/intl/Pages/ANXX0002.htm
		{Jeddah/Abdul Aziz,,Arabie Saoudite} /Meteo/Villes/intl/Pages/SAXX0011.htm
		{Riyad,,Arabie Saoudite} /Meteo/Villes/intl/Pages/SAXX0017.htm
		{Buenos Aires,,Argentine} /Meteo/Villes/intl/Pages/ARXX0009.htm
		Cordoba,,Argentine /Meteo/Villes/intl/Pages/ARXX0023.htm
		Rosario,,Argentine /Meteo/Villes/intl/Pages/ARXX0078.htm
		Yerevan,,Arménie /Meteo/Villes/intl/Pages/AMXX0003.htm
		Oranjestad,,Aruba /Meteo/Villes/intl/Pages/AAXX0001.htm
		{Queen Beatrix Arpt,,Aruba} /Meteo/Villes/intl/Pages/AAXX0002.htm
		Adelaïde,,Australie /Meteo/Villes/intl/Pages/AUSA0001.htm
		Brisbane,,Australie /Meteo/Villes/intl/Pages/AUQL0001.htm
		Canberra,,Australie /Meteo/Villes/intl/Pages/ASXX0023.htm
		Darwin,,Australie /Meteo/Villes/intl/Pages/AUNT0001.htm
		Melbourne,,Australie /Meteo/Villes/intl/Pages/AUVI0001.htm
		Perth,,Australie /Meteo/Villes/intl/Pages/AUWA0001.htm
		Sydney,,Australie /Meteo/Villes/intl/Pages/AUNS0001.htm
		Landeck,,Autriche /Meteo/Villes/intl/Pages/ITXX0098.htm
		Salzbourg,,Autriche /Meteo/Villes/intl/Pages/AUXX0018.htm
		Vienne,,Autriche /Meteo/Villes/intl/Pages/AUXX0025.htm
		Zeltweg,,Autriche /Meteo/Villes/intl/Pages/AUXX0055.htm
		Baku,,Azerbaijan /Meteo/Villes/intl/Pages/AJXX0001.htm
		Freeport,,Bahamas /Meteo/Villes/intl/Pages/BFXX0002.htm
		{George Town,,Bahamas} /Meteo/Villes/intl/Pages/BFXX0006.htm
		Nassau,,Bahamas /Meteo/Villes/intl/Pages/BFXX0005.htm
		{Al Manama,,Bahreïn} /Meteo/Villes/intl/Pages/BAXX0001.htm
		Dhaka,,Bangladesh /Meteo/Villes/intl/Pages/BGXX0003.htm
		Bridgetown,,Barbade /Meteo/Villes/intl/Pages/BBXX0001.htm
		Minsk,,Bélarus /Meteo/Villes/intl/Pages/BOXX0005.htm
		Bruxelles,,Belgique /Meteo/Villes/intl/Pages/BEXX0005.htm
		Bélize,,Belize /Meteo/Villes/intl/Pages/BHXX0001.htm
		Porto-Novo,,Bénin /Meteo/Villes/intl/Pages/BNXX0002.htm
		Hamilton,,Bermudes /Meteo/Villes/intl/Pages/BMXX0006.htm
		{La Paz,,Bolivie} /Meteo/Villes/intl/Pages/BLXX0006.htm
		Sarajevo,,Bosnie-Herzégovine /Meteo/Villes/intl/Pages/BKXX0004.htm
		Gaberone/Khama,,Botswana /Meteo/Villes/intl/Pages/BCXX0005.htm
		Belem,,Brésil /Meteo/Villes/intl/Pages/BRXX0032.htm
		{Belo Horizonte,,Brésil} /Meteo/Villes/intl/Pages/BRXX0033.htm
		Brasília,,Brésil /Meteo/Villes/intl/Pages/BRXX0043.htm
		{Porto Alegre,,Brésil} /Meteo/Villes/intl/Pages/BRXX0186.htm
		{Rio de Janeiro,,Brésil} /Meteo/Villes/intl/Pages/BRXX0201.htm
		{Sao Paulo,,Brésil} /Meteo/Villes/intl/Pages/BRXX0232.htm
		{Brunei,,Brunei Darussalam} /Meteo/Villes/intl/Pages/BNXX0004.htm
		Sofia,,Bulgarie /Meteo/Villes/intl/Pages/BUXX0005.htm
		{Ouagadougou,,Burkina Faso} /Meteo/Villes/intl/Pages/UVXX0001.htm
		Bujumbura,,Burundi /Meteo/Villes/intl/Pages/BYXX0001.htm
		{Phnom Penh,,Cambodge} /Meteo/Villes/intl/Pages/CBXX0001.htm
		{100 Mile House,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0001.htm
		{108 Mile House,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0002.htm
		{108 Mile Ranch,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0003.htm
		{150 Mile House,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0004.htm
		Abbey,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0001.htm
		Abbotsford,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0006.htm
		Aberarder,Ontario,Canada /Meteo/Villes/can/Pages/CAON0001.htm
		Abercorn,Québec,Canada /Meteo/Villes/can/Pages/CAQC0001.htm
		Aberdeen,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0002.htm
		Abernethy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0003.htm
		{Abitibi Canyon,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0002.htm
		{Acadia Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0001.htm
		Acme,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0002.htm
		{Acton Vale,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0002.htm
		Acton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0003.htm
		Adamsville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0188.htm
		Adolphustown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0004.htm
		{Advocate Harbour,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0001.htm
		{Agassiz Provincial Forest,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0001.htm
		Agassiz,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0007.htm
		Aguanish,Québec,Canada /Meteo/Villes/can/Pages/CAQC0004.htm
		Ahousat,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0008.htm
		{Ailsa Craig,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0005.htm
		Airdrie,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0003.htm
		Ajax,Ontario,Canada /Meteo/Villes/can/Pages/CAON0006.htm
		{Aklavik,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0001.htm
		Alameda,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0004.htm
		Albanel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0006.htm
		Alban,Ontario,Canada /Meteo/Villes/can/Pages/CAON0007.htm
		{Albert Mines,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0002.htm
		{Alberta Beach,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0004.htm
		Alberton,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0001.htm
		Albert,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0001.htm
		{Alder Flats,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0005.htm
		Aldergrove,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0010.htm
		{Alderville First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1530.htm
		{Alert Bay,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0011.htm
		Alexander,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0002.htm
		Alexandria,Ontario,Canada /Meteo/Villes/can/Pages/CAON0008.htm
		{Alexis Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0012.htm
		Alfred,Ontario,Canada /Meteo/Villes/can/Pages/CAON0009.htm
		{Algoma Mills,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0010.htm
		Alida,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0005.htm
		Alix,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0006.htm
		{Alkali Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0013.htm
		Allan,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0006.htm
		Allardville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0003.htm
		Alliance,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0007.htm
		Alliston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0012.htm
		Alma,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0004.htm
		Alma,Québec,Canada /Meteo/Villes/can/Pages/CAQC0007.htm
		Almonte,Ontario,Canada /Meteo/Villes/can/Pages/CAON0013.htm
		Alonsa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0003.htm
		Alouette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0216.htm
		Alsask,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0007.htm
		Altario,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0008.htm
		Altona,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0004.htm
		Alvena,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0008.htm
		Alvinston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0014.htm
		Amherstburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0015.htm
		Amherstview,Ontario,Canada /Meteo/Villes/can/Pages/CAON2007.htm
		Amherst,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0002.htm
		Amos,Québec,Canada /Meteo/Villes/can/Pages/CAQC0008.htm
		Amqui,Québec,Canada /Meteo/Villes/can/Pages/CAQC0009.htm
		Ancaster,Ontario,Canada /Meteo/Villes/can/Pages/CAON0016.htm
		Andrew,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0009.htm
		Aneroid,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0009.htm
		Angliers,Québec,Canada /Meteo/Villes/can/Pages/CAQC0010.htm
		Angus,Ontario,Canada /Meteo/Villes/can/Pages/CAON0017.htm
		{Anjou (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0011.htm
		{Annapolis Royal,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0003.htm
		Anse-Saint-Jean,Québec,Canada /Meteo/Villes/can/Pages/CAQC0012.htm
		Antigonish,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0004.htm
		Anzac,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0010.htm
		{Appleton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0001.htm
		Apsley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0018.htm
		Arborfield,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0011.htm
		Arborg,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0007.htm
		Archerwill,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0012.htm
		Arcola,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0013.htm
		Arden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0019.htm
		Ardrossan,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0011.htm
		{Argentia,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0002.htm
		Argyle,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0005.htm
		Arichat,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0006.htm
		Arkell,Ontario,Canada /Meteo/Villes/can/Pages/CAON1618.htm
		Arkona,Ontario,Canada /Meteo/Villes/can/Pages/CAON0020.htm
		Armagh,Québec,Canada /Meteo/Villes/can/Pages/CAQC0013.htm
		Armstrong,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0014.htm
		Armstrong,Ontario,Canada /Meteo/Villes/can/Pages/CAON0021.htm
		{Arnold's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0003.htm
		Arnprior,Ontario,Canada /Meteo/Villes/can/Pages/CAON0022.htm
		Arrowwood,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0012.htm
		Arthur,Ontario,Canada /Meteo/Villes/can/Pages/CAON0023.htm
		Arundel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0015.htm
		Arviat,Nunavut,Canada /Meteo/Villes/can/Pages/CANU0002.htm
		Asbestos,Québec,Canada /Meteo/Villes/can/Pages/CAQC0016.htm
		{Ascot Corner,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0427.htm
		Ascot,Québec,Canada /Meteo/Villes/can/Pages/CAQC0424.htm
		Ashcroft,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0015.htm
		Ashern,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0009.htm
		Ashmont,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0013.htm
		Asquith,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0014.htm
		Assiniboia,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0015.htm
		Assumption,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0014.htm
		Aston-Jonction,Québec,Canada /Meteo/Villes/can/Pages/CAQC0017.htm
		Athabasca,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0015.htm
		Athens,Ontario,Canada /Meteo/Villes/can/Pages/CAON0024.htm
		Atikokan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0025.htm
		Atlin,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0017.htm
		Attawapiskat,Ontario,Canada /Meteo/Villes/can/Pages/CAON0026.htm
		Atwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0027.htm
		Auburn,Ontario,Canada /Meteo/Villes/can/Pages/CAON0028.htm
		Aupaluk,Québec,Canada /Meteo/Villes/can/Pages/CAQC1084.htm
		Aurora,Ontario,Canada /Meteo/Villes/can/Pages/CAON0029.htm
		Austin,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0010.htm
		Avola,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0018.htm
		{Avondale,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0004.htm
		Avonlea,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0016.htm
		Avonmore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0030.htm
		{Ayer's Cliff,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0019.htm
		Aylesford,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0007.htm
		{Aylmer (Gatineau),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0020.htm
		Aylmer,Ontario,Canada /Meteo/Villes/can/Pages/CAON0031.htm
		Ayr,Ontario,Canada /Meteo/Villes/can/Pages/CAON0032.htm
		Ayton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0033.htm
		Azilda,Ontario,Canada /Meteo/Villes/can/Pages/CAON0034.htm
		Baddeck,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0008.htm
		Baden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0035.htm
		{Badger,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0005.htm
		Bagotville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0003.htm
		{Baie Verte,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0006.htm
		Baie-Comeau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0022.htm
		Baie-Johan-Beetz,Québec,Canada /Meteo/Villes/can/Pages/CAQC0027.htm
		Baie-Saint-Paul,Québec,Canada /Meteo/Villes/can/Pages/CAQC0028.htm
		Baie-Sainte-Catherine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0029.htm
		Baie-Ste-Anne,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0005.htm
		Baie-Trinité,Québec,Canada /Meteo/Villes/can/Pages/CAQC0030.htm
		{Baie-d'Urfé (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0023.htm
		Baie-de-Shawinigan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0024.htm
		Baie-des-Sables,Québec,Canada /Meteo/Villes/can/Pages/CAQC0025.htm
		Baie-du-Febvre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0026.htm
		Bailieboro,Ontario,Canada /Meteo/Villes/can/Pages/CAON0036.htm
		{Baker Brook,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0006.htm
		{Baker Lake,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0003.htm
		Bala,Ontario,Canada /Meteo/Villes/can/Pages/CAON0037.htm
		Balcarres,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0017.htm
		Baldur,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0011.htm
		Balfour,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0019.htm
		Balgonie,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0018.htm
		Balmertown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0038.htm
		Balmoral,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0007.htm
		Baltimore,Ontario,Canada /Meteo/Villes/can/Pages/CAON1722.htm
		Bamfield,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0020.htm
		Bancroft,Ontario,Canada /Meteo/Villes/can/Pages/CAON0039.htm
		Banff,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0016.htm
		Barachois,Québec,Canada /Meteo/Villes/can/Pages/CAQC0032.htm
		Barkmere,Québec,Canada /Meteo/Villes/can/Pages/CAQC0033.htm
		Barons,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0017.htm
		Barraute,Québec,Canada /Meteo/Villes/can/Pages/CAQC0034.htm
		Barrhead,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0018.htm
		Barrière,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0021.htm
		Barrie,Ontario,Canada /Meteo/Villes/can/Pages/CAON0040.htm
		{Barry's Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0041.htm
		Barwick,Ontario,Canada /Meteo/Villes/can/Pages/CAON0042.htm
		Bashaw,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0019.htm
		{Bass River,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0010.htm
		Bassano,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0020.htm
		Basswood,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0012.htm
		Batawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON1723.htm
		{Batchawana Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0043.htm
		Bathurst,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0009.htm
		Bath,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0008.htm
		Bath,Ontario,Canada /Meteo/Villes/can/Pages/CAON0044.htm
		Batiscan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0035.htm
		{Batteau,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0007.htm
		{Battle Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0008.htm
		Battleford,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0019.htm
		{Bauline,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0009.htm
		Bawlf,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0021.htm
		{Bay Bulls,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0010.htm
		{Bay L'Argent,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0012.htm
		{Bay Roberts,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0013.htm
		{Bay de Verde,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0011.htm
		Bayfield,Ontario,Canada /Meteo/Villes/can/Pages/CAON0045.htm
		Baysville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0046.htm
		{Beach Grove,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0022.htm
		Beachburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0047.htm
		{Beachside,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANL0068.htm
		Beachville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0048.htm
		{Beaconsfield (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0036.htm
		Beamsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0049.htm
		{Bear Canyon,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0022.htm
		{Bear Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0023.htm
		{Bear River,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0011.htm
		{Bear's Passage,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0050.htm
		Beardmore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0051.htm
		{Bearskin Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1501.htm
		{Bearskin Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0052.htm
		Beaucanton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0038.htm
		Beauceville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0039.htm
		Beauharnois,Québec,Canada /Meteo/Villes/can/Pages/CAQC0040.htm
		Beaulac-Garthby,Québec,Canada /Meteo/Villes/can/Pages/CAQC0175.htm
		Beaumont,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0023.htm
		Beaumont,Québec,Canada /Meteo/Villes/can/Pages/CAQC0428.htm
		{Beaumont,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0014.htm
		{Beauport (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0042.htm
		Beaupré,Québec,Canada /Meteo/Villes/can/Pages/CAQC0043.htm
		Beausejour,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0013.htm
		Beauval,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0020.htm
		{Beaver Cove,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0025.htm
		{Beaver Creek,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0001.htm
		Beaverdell,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0027.htm
		Beaverlodge,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0024.htm
		Beaverton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0053.htm
		Bécancour,Québec,Canada /Meteo/Villes/can/Pages/CAQC0044.htm
		Bedeque,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0002.htm
		Bedford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0045.htm
		Beechy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0021.htm
		Beeton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0054.htm
		Beiseker,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0025.htm
		{Bell Island,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0015.htm
		{Bella Bella,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0028.htm
		{Bella Coola,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0029.htm
		{Belle Neige,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1286.htm
		{Belle River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0055.htm
		Belledune,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0010.htm
		Bellefeuille,Québec,Canada /Meteo/Villes/can/Pages/CAQC0434.htm
		{Belleoram,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0016.htm
		Belleterre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0046.htm
		Belleville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0056.htm
		{Bellevue,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0017.htm
		Belmont,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0014.htm
		Belmont,Ontario,Canada /Meteo/Villes/can/Pages/CAON0057.htm
		Beloeil,Québec,Canada /Meteo/Villes/can/Pages/CAQC0047.htm
		Bengough,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0022.htm
		Benito,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0015.htm
		{Benoit's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0018.htm
		Bentley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0026.htm
		{Berens River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0016.htm
		Beresford,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0011.htm
		Bergeronnes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0048.htm
		Berthierville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0050.htm
		Berwick,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0013.htm
		Berwyn,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0027.htm
		Bethany,Ontario,Canada /Meteo/Villes/can/Pages/CAON0058.htm
		Bethesda,Ontario,Canada /Meteo/Villes/can/Pages/CAON0059.htm
		Bethune,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0023.htm
		Betsiamites,Québec,Canada /Meteo/Villes/can/Pages/CAQC0051.htm
		Beulah,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0017.htm
		Biencourt,Québec,Canada /Meteo/Villes/can/Pages/CAQC0052.htm
		Bienfait,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0024.htm
		{Big River,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0025.htm
		{Big Trout Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0060.htm
		{Big Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0028.htm
		Biggar,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0026.htm
		Binbrook,Ontario,Canada /Meteo/Villes/can/Pages/CAON0061.htm
		Bindloss,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0029.htm
		Binscarth,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0018.htm
		{Birch Hills,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0027.htm
		{Birch Island,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0789.htm
		{Birchy Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0019.htm
		Birsay,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0028.htm
		Birtle,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0020.htm
		Biscotasing,Ontario,Canada /Meteo/Villes/can/Pages/CAON0062.htm
		{Bishop's Falls,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0020.htm
		Bishopton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0053.htm
		Bissett,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0021.htm
		{Black Creek (Williams Lake),Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0340.htm
		{Black Creek (near Campbell River),Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0016.htm
		{Black Diamond,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0030.htm
		{Black Duck Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0021.htm
		{Black Lake,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0054.htm
		{Black Point,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0030.htm
		{Black Tickle,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0022.htm
		Blackfalds,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0031.htm
		Blackie,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0032.htm
		{Blacks Harbour,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0012.htm
		Blackstock,Ontario,Canada /Meteo/Villes/can/Pages/CAON0063.htm
		Blackville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0013.htm
		{Blaine Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0031.htm
		Blainville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0055.htm
		Blanc-Sablon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0056.htm
		Blandford,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0014.htm
		Blenheim,Ontario,Canada /Meteo/Villes/can/Pages/CAON0064.htm
		{Blezard Valley,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0065.htm
		Blindriver,Ontario,Canada /Meteo/Villes/can/Pages/CAON0066.htm
		Bloomfield,Ontario,Canada /Meteo/Villes/can/Pages/CAON0067.htm
		{Blue Ridge,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0033.htm
		{Blue River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0032.htm
		Blyth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0069.htm
		{Bob Quinn Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0033.htm
		Bobcaygeon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0070.htm
		Boiestown,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0014.htm
		Bois-des-Filion,Québec,Canada /Meteo/Villes/can/Pages/CAQC0057.htm
		Boisbriand,Québec,Canada /Meteo/Villes/can/Pages/CAQC0058.htm
		Boischatel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0059.htm
		Boisdale,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0015.htm
		Boissevain,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0023.htm
		Bolton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0071.htm
		{Bon Accord,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0034.htm
		Bonanza,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0035.htm
		Bonaventure,Québec,Canada /Meteo/Villes/can/Pages/CAQC0060.htm
		{Bonavista,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0023.htm
		Bonfield,Ontario,Canada /Meteo/Villes/can/Pages/CAON0072.htm
		Bonne-Espérance,Québec,Canada /Meteo/Villes/can/Pages/CAQC0061.htm
		Bonnyville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0036.htm
		Borden,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0003.htm
		Borden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0073.htm
		Borden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0032.htm
		{Boston Bar,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0034.htm
		Boswell,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0035.htm
		Bothwell,Ontario,Canada /Meteo/Villes/can/Pages/CAON0074.htm
		{Botwood,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0024.htm
		Boucherville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0062.htm
		Bouchette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0063.htm
		Bouctouche,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0015.htm
		Boularderie,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0016.htm
		Bourget,Ontario,Canada /Meteo/Villes/can/Pages/CAON0075.htm
		{Bow Island,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0037.htm
		Bowden,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0038.htm
		{Bowen Island,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0037.htm
		Bowmanville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0076.htm
		Bowser,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0038.htm
		{Boyd's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0025.htm
		Boyle,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0039.htm
		Bracebridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0077.htm
		{Bradford West Gwillimbury,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0079.htm
		Bradford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0078.htm
		Braeside,Ontario,Canada /Meteo/Villes/can/Pages/CAON1724.htm
		{Bragg Creek,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0040.htm
		Brampton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0080.htm
		{Branch,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0026.htm
		Brandon,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0025.htm
		Brantford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0081.htm
		Brant,Ontario,Canada /Meteo/Villes/can/Pages/CAON0598.htm
		Breakeyville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0762.htm
		Brechin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0082.htm
		Bredenbury,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0033.htm
		{Brent's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0027.htm
		Breslau,Ontario,Canada /Meteo/Villes/can/Pages/CAON0083.htm
		Breton,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0041.htm
		{Bridge Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0040.htm
		Bridgenorth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0084.htm
		Bridgetown,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0017.htm
		Bridgewater,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0018.htm
		Briercrest,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0034.htm
		Brigden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0085.htm
		Brigham,Québec,Canada /Meteo/Villes/can/Pages/CAQC1189.htm
		Brighton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0087.htm
		{Brights Grove,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0088.htm
		Bright,Ontario,Canada /Meteo/Villes/can/Pages/CAON0086.htm
		{Brigus,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0029.htm
		{Britannia Beach,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0042.htm
		Britt,Ontario,Canada /Meteo/Villes/can/Pages/CAON0089.htm
		Broadview,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0035.htm
		Brochet,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0026.htm
		Brocket,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0042.htm
		Brockville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0090.htm
		Brock,Ontario,Canada /Meteo/Villes/can/Pages/CAON2014.htm
		Brock,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0036.htm
		Brome,Québec,Canada /Meteo/Villes/can/Pages/CAQC0064.htm
		Bromont,Québec,Canada /Meteo/Villes/can/Pages/CAQC1287.htm
		{Bromptonville (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0066.htm
		Brookdale,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0028.htm
		Brookfield,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0019.htm
		Brooklin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0091.htm
		Brooks,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0043.htm
		Brossard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0067.htm
		{Browns Flat,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0017.htm
		Brownsburg,Québec,Canada /Meteo/Villes/can/Pages/CAQC0068.htm
		Brownsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0092.htm
		Brownvale,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0044.htm
		{Bruce Mines,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0093.htm
		Bruderheim,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0045.htm
		Bruno,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0037.htm
		Bruxelles,Ontario,Canada /Meteo/Villes/can/Pages/CAON0094.htm
		Bryson,Québec,Canada /Meteo/Villes/can/Pages/CAQC0069.htm
		Buchanan,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0038.htm
		{Buchans,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0031.htm
		Buckhorn,Ontario,Canada /Meteo/Villes/can/Pages/CAON0095.htm
		{Buckingham (Gatineau),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0070.htm
		{Buffalo Narrows,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0039.htm
		Burdett,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0046.htm
		Burford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0096.htm
		{Burgeo,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0032.htm
		Burgessville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0097.htm
		{Burin,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0033.htm
		{Burk's Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0098.htm
		{Burleigh Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0099.htm
		Burlington,Ontario,Canada /Meteo/Villes/can/Pages/CAON0100.htm
		{Burlington,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0034.htm
		Burnaby,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0043.htm
		{Burns Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0044.htm
		{Burnt Islands,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0035.htm
		Burstall,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0040.htm
		{Burwash Landing,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0002.htm
		Bury,Québec,Canada /Meteo/Villes/can/Pages/CAQC0071.htm
		Byemoor,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0047.htm
		Cabano,Québec,Canada /Meteo/Villes/can/Pages/CAQC0072.htm
		Cabri,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0041.htm
		{Cache Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0101.htm
		{Cache Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0045.htm
		Cacouna,Québec,Canada /Meteo/Villes/can/Pages/CAQC1190.htm
		{Cadboro Bay,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0411.htm
		Cadillac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0073.htm
		Cadillac,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0042.htm
		Cadomin,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0048.htm
		Calabogie,Ontario,Canada /Meteo/Villes/can/Pages/CAON0102.htm
		Calder,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0043.htm
		{Caledon East,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0104.htm
		Caledonia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0105.htm
		Caledon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0103.htm
		Calgary,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0049.htm
		Callander,Ontario,Canada /Meteo/Villes/can/Pages/CAON0106.htm
		{Calling Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0050.htm
		Calmar,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0051.htm
		Calstock,Ontario,Canada /Meteo/Villes/can/Pages/CAON0107.htm
		Calumet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0074.htm
		Cambray,Ontario,Canada /Meteo/Villes/can/Pages/CAON0108.htm
		{Cambridge Bay,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0005.htm
		Cambridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0109.htm
		Cameron,Ontario,Canada /Meteo/Villes/can/Pages/CAON0110.htm
		Camlachie,Ontario,Canada /Meteo/Villes/can/Pages/CAON1725.htm
		{Campbell River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0046.htm
		{Campbell's Bay,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0075.htm
		Campbellford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0111.htm
		Campbellton,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0018.htm
		{Campbellton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0036.htm
		Campbellville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0112.htm
		Camperville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0029.htm
		{Campobello Island,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0019.htm
		Camrose,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0052.htm
		{Canal Flats,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0047.htm
		Candiac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0076.htm
		Canmore,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0053.htm
		Cannington,Ontario,Canada /Meteo/Villes/can/Pages/CAON0113.htm
		Canning,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0022.htm
		{Canoe Narrows,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0044.htm
		Canora,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0045.htm
		Canso,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0023.htm
		Canteburry,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0020.htm
		Cantley,Québec,Canada /Meteo/Villes/can/Pages/CAQC1191.htm
		Canwood,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0046.htm
		Cap-Chat,Québec,Canada /Meteo/Villes/can/Pages/CAQC0079.htm
		Cap-Pele,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0021.htm
		{Cap-Rouge (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0082.htm
		Cap-Saint-Ignace,Québec,Canada /Meteo/Villes/can/Pages/CAQC0083.htm
		Cap-à-l'Aigle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0077.htm
		{Cap-de-la-Madeleine (Trois-Rivières),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0080.htm
		Cap-des-Rosiers,Québec,Canada /Meteo/Villes/can/Pages/CAQC0081.htm
		{Cape Broyle,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0037.htm
		{Cape Dorset,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0006.htm
		Caplan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0084.htm
		Capreol,Ontario,Canada /Meteo/Villes/can/Pages/CAON0114.htm
		{Caradoc First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1554.htm
		Caramat,Ontario,Canada /Meteo/Villes/can/Pages/CAON0115.htm
		Caraquet,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0022.htm
		Carberry,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0030.htm
		{Carbonear,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0038.htm
		Carbon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0054.htm
		Carcross,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0003.htm
		Cardiff,Ontario,Canada /Meteo/Villes/can/Pages/CAON0116.htm
		Cardigan,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0004.htm
		Cardinal,Ontario,Canada /Meteo/Villes/can/Pages/CAON0117.htm
		Cardston,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0055.htm
		Cargill,Ontario,Canada /Meteo/Villes/can/Pages/CAON0118.htm
		Caribou,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0024.htm
		Carievale,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0047.htm
		Carignan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0085.htm
		Carillon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0086.htm
		{Carleton Place,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0119.htm
		Carleton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0025.htm
		Carleton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0087.htm
		Carlyle,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0048.htm
		Carmacks,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0004.htm
		Carmangay,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0056.htm
		{Carmanville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0039.htm
		Carman,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0031.htm
		Carnarvon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0120.htm
		Carnduff,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0049.htm
		Caroline,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0057.htm
		Caron,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0050.htm
		Carp,Ontario,Canada /Meteo/Villes/can/Pages/CAON0121.htm
		{Carrot River,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0051.htm
		Carseland,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0174.htm
		Carstairs,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0058.htm
		Cartier,Ontario,Canada /Meteo/Villes/can/Pages/CAON0122.htm
		Cartwright,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0032.htm
		{Cartwright,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0040.htm
		Casselman,Ontario,Canada /Meteo/Villes/can/Pages/CAON0123.htm
		Cassiar,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0048.htm
		Castlegar,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0049.htm
		Castlemore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0124.htm
		Castleton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0125.htm
		Castor,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0059.htm
		{Cat Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0126.htm
		{Catalina,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0041.htm
		Causapscal,Québec,Canada /Meteo/Villes/can/Pages/CAQC0088.htm
		Cavan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0127.htm
		Cavendish,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0102.htm
		Cayley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0060.htm
		Cayuga,Ontario,Canada /Meteo/Villes/can/Pages/CAON0128.htm
		Celista,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0051.htm
		{Central Butte,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0052.htm
		Centralia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0129.htm
		{Centreville-Wareham-Trinity,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0043.htm
		Centreville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0023.htm
		Cereal,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0061.htm
		Cessford,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0062.htm
		Ceylon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0053.htm
		{Chalk River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0130.htm
		Chambly,Québec,Canada /Meteo/Villes/can/Pages/CAQC0089.htm
		Chambord,Québec,Canada /Meteo/Villes/can/Pages/CAQC0090.htm
		Champion,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0063.htm
		Champlain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0091.htm
		{Chance Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0044.htm
		{Change Islands,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0045.htm
		Chapais,Québec,Canada /Meteo/Villes/can/Pages/CAQC0093.htm
		Chapeau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0094.htm
		{Chapel Arm,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0047.htm
		Chapleau,Ontario,Canada /Meteo/Villes/can/Pages/CAON0131.htm
		Chaplin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0054.htm
		Charette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0095.htm
		Charlemagne,Québec,Canada /Meteo/Villes/can/Pages/CAQC0096.htm
		{Charlesbourg (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0097.htm
		Charlevoix,Québec,Canada /Meteo/Villes/can/Pages/CAQC0800.htm
		Charlottetown,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0005.htm
		{Charlottetown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0048.htm
		Charlton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0132.htm
		{Charny (Lévis),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0098.htm
		Chartierville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0099.htm
		Chase,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0052.htm
		Château-Richer,Québec,Canada /Meteo/Villes/can/Pages/CAQC0100.htm
		Chateauguay,Québec,Canada /Meteo/Villes/can/Pages/CAQC0101.htm
		Chatham,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0024.htm
		Chatham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0133.htm
		Chatsworth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0134.htm
		Chauvin,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0064.htm
		Chelmsford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0135.htm
		Chelsea,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0026.htm
		Chelsea,Québec,Canada /Meteo/Villes/can/Pages/CAQC0102.htm
		Chemainus,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0053.htm
		Chénéville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0103.htm
		Chertsey,Québec,Canada /Meteo/Villes/can/Pages/CAQC0527.htm
		Chesley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0136.htm
		{Chesterfield Inlet,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0007.htm
		Chestermere,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0065.htm
		Chesterville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0137.htm
		Chesterville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0104.htm
		Chester,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0027.htm
		Chéticamp,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0028.htm
		Chetwynd,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0054.htm
		Cheverie,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0029.htm
		Chevery,Québec,Canada /Meteo/Villes/can/Pages/CAQC0105.htm
		Chibougamau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0106.htm
		{Chicoutimi (Saguenay),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0107.htm
		{Chiefs Point First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1533.htm
		Chilliwack,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0057.htm
		{Chipewyan Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0066.htm
		Chipman,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0067.htm
		Chipman,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0025.htm
		{Chippewas Of Sarnia First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1523.htm
		{Chippewas of Kettle/Stony Point First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1517.htm
		Chisasibi,Québec,Canada /Meteo/Villes/can/Pages/CAQC0108.htm
		Choiceland,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0055.htm
		Chomedey,Québec,Canada /Meteo/Villes/can/Pages/CAQC0109.htm
		{Christian Island,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0138.htm
		{Christina Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0058.htm
		{Christopher Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0056.htm
		Churchbridge,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0057.htm
		{Churchill Falls,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0049.htm
		Churchill,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0033.htm
		Chute-aux-Outardes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0110.htm
		Chute-des-Passes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0111.htm
		Clairmont,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0068.htm
		Clair,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0026.htm
		Claremont,Ontario,Canada /Meteo/Villes/can/Pages/CAON0140.htm
		{Clarence Creek,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0141.htm
		Clarence-Rockland,Ontario,Canada /Meteo/Villes/can/Pages/CAON1383.htm
		{Clarenville-Shoal Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0051.htm
		{Clarenville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0050.htm
		Claresholm,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0069.htm
		Clarington,Ontario,Canada /Meteo/Villes/can/Pages/CAON0142.htm
		{Clark's Harbour,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0031.htm
		{Clarke's Beach,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0052.htm
		{Clarks Corners,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0027.htm
		Clarkson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0143.htm
		Clarksville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0032.htm
		Clavet,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0440.htm
		{Clearwater Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0144.htm
		Clearwater,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0059.htm
		Cléricy,Québec,Canada /Meteo/Villes/can/Pages/CAQC0115.htm
		Clermont,Québec,Canada /Meteo/Villes/can/Pages/CAQC0116.htm
		Clifford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0145.htm
		Climax,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0058.htm
		Clinton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0060.htm
		Clinton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0146.htm
		Clive,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0070.htm
		Cloridorme,Québec,Canada /Meteo/Villes/can/Pages/CAQC0117.htm
		{Cloud Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0147.htm
		Clova,Québec,Canada /Meteo/Villes/can/Pages/CAQC0118.htm
		Clyde,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0071.htm
		Coaldale,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0072.htm
		Coalhurst,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0073.htm
		Coaticook,Québec,Canada /Meteo/Villes/can/Pages/CAQC0119.htm
		Cobalt,Ontario,Canada /Meteo/Villes/can/Pages/CAON0148.htm
		{Cobble Hill,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0063.htm
		Cobden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0149.htm
		Coboconk,Ontario,Canada /Meteo/Villes/can/Pages/CAON0150.htm
		Cobourg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0151.htm
		Cocagne,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0028.htm
		Cochenour,Ontario,Canada /Meteo/Villes/can/Pages/CAON0152.htm
		Cochin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0059.htm
		Cochrane,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0074.htm
		Cochrane,Ontario,Canada /Meteo/Villes/can/Pages/CAON0153.htm
		Coderre,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0060.htm
		{Codroy,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0054.htm
		{Coe Hill,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0154.htm
		Colborne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0155.htm
		Colchester,Ontario,Canada /Meteo/Villes/can/Pages/CAON1726.htm
		{Cold Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0075.htm
		{Cold Springs,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0156.htm
		Coldwater,Ontario,Canada /Meteo/Villes/can/Pages/CAON0157.htm
		Coleville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0061.htm
		{Colliers,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0055.htm
		{Collingwood Corner,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0033.htm
		Collingwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0158.htm
		Colombier,Québec,Canada /Meteo/Villes/can/Pages/CAQC0120.htm
		Colonsay,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0062.htm
		Colwood,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0064.htm
		Comber,Ontario,Canada /Meteo/Villes/can/Pages/CAON0160.htm
		{Come By Chance,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0056.htm
		{Comfort Cove-Newstead,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0057.htm
		Commanda,Ontario,Canada /Meteo/Villes/can/Pages/CAON2033.htm
		Comox,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0065.htm
		Compton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0121.htm
		{Conception Bay South,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0058.htm
		{Conception Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0059.htm
		{Conche,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0060.htm
		Concord,Ontario,Canada /Meteo/Villes/can/Pages/CAON1763.htm
		Coniston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0161.htm
		Conklin,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0076.htm
		Connaught,Ontario,Canada /Meteo/Villes/can/Pages/CAON0162.htm
		{Conne River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0061.htm
		Conquest,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0063.htm
		Consort,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0077.htm
		{Constance Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0163.htm
		{Constance Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1522.htm
		Consul,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0064.htm
		Contrecoeur,Québec,Canada /Meteo/Villes/can/Pages/CAQC0122.htm
		{Cook's Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0062.htm
		Cookshire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0123.htm
		Cookstown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0164.htm
		Cooksville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0165.htm
		Coquitlam,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0066.htm
		{Coral Harbour,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0009.htm
		Cormorant,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0037.htm
		{Corner Brook,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0063.htm
		Cornwall,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0006.htm
		Cornwall,Ontario,Canada /Meteo/Villes/can/Pages/CAON0166.htm
		Coronach,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0065.htm
		Coronation,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0078.htm
		Corunna,Ontario,Canada /Meteo/Villes/can/Pages/CAON0167.htm
		{Côte-Saint-Luc (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0124.htm
		Coteau-du-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0126.htm
		Cottam,Ontario,Canada /Meteo/Villes/can/Pages/CAON0168.htm
		{Cottlesville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0064.htm
		Courcelette,Québec,Canada /Meteo/Villes/can/Pages/CAQC1196.htm
		Courcelles,Québec,Canada /Meteo/Villes/can/Pages/CAQC0127.htm
		Courtenay,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0068.htm
		Courtice,Ontario,Canada /Meteo/Villes/can/Pages/CAON0775.htm
		Courtright,Ontario,Canada /Meteo/Villes/can/Pages/CAON0169.htm
		Coutts,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0079.htm
		Covehead,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0007.htm
		{Cow Head,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0066.htm
		Cowansville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0128.htm
		Cowan,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0038.htm
		{Cowichan Bay,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0069.htm
		Cowley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0080.htm
		Crabtree,Québec,Canada /Meteo/Villes/can/Pages/CAQC0129.htm
		Craigmyle,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0081.htm
		Craik,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0066.htm
		{Cranberry Portage,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0039.htm
		Cranbrook,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0070.htm
		Crandall,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0040.htm
		Crapaud,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0008.htm
		{Crawford Bay,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0071.htm
		Crediton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0170.htm
		Creelman,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0067.htm
		Creemore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0171.htm
		Creighton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0068.htm
		Cremona,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0082.htm
		{Crescent Beach,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0751.htm
		Creston,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0072.htm
		{Cross Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0042.htm
		Crossfield,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0083.htm
		{Crowsnest Pass,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0084.htm
		Crysler,Ontario,Canada /Meteo/Villes/can/Pages/CAON0172.htm
		{Crystal Beach,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0776.htm
		{Crystal City,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0043.htm
		Cudworth,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0069.htm
		{Cumberland House,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0070.htm
		Cumberland,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0073.htm
		Cumberland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0173.htm
		Cupar,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0071.htm
		{Cupids,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0067.htm
		{Cut Knife,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0072.htm
		{Cypress River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0044.htm
		Czar,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0085.htm
		D'arcy,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0074.htm
		Dalhousie,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0029.htm
		Dalmeny,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0074.htm
		{Daniel's Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0068.htm
		Danville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0131.htm
		Darlingford,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0045.htm
		Dartmouth,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0036.htm
		Dashwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0174.htm
		Dauphin,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0046.htm
		Daveluyville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0132.htm
		Davidson,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0075.htm
		{Dawson Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0076.htm
		Dawson,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0005.htm
		Daysland,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0086.htm
		DeBolt,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0087.htm
		{Dease Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0077.htm
		{Deauville (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0133.htm
		Debden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0076.htm
		Debec,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0030.htm
		Debert,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0037.htm
		{Deep River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0175.htm
		{Deer Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0176.htm
		{Deer Lake,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0070.htm
		Deerbrook,Ontario,Canada /Meteo/Villes/can/Pages/CAON0773.htm
		Degelis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0134.htm
		{Delaware of the Thames(Moravian Town),Ontario,Canada} /Meteo/Villes/can/Pages/CAON1575.htm
		Delburne,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0088.htm
		Delhi,Ontario,Canada /Meteo/Villes/can/Pages/CAON0177.htm
		Delia,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0089.htm
		Delisle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0135.htm
		Delisle,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0077.htm
		Deloraine,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0047.htm
		Delson,Québec,Canada /Meteo/Villes/can/Pages/CAQC0136.htm
		Delta,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0079.htm
		Delta,Ontario,Canada /Meteo/Villes/can/Pages/CAON0178.htm
		Denbigh,Ontario,Canada /Meteo/Villes/can/Pages/CAON0179.htm
		Denzil,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0079.htm
		Derwent,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0090.htm
		Desbarats,Ontario,Canada /Meteo/Villes/can/Pages/CAON0180.htm
		Desbiens,Québec,Canada /Meteo/Villes/can/Pages/CAQC0137.htm
		Deschaillons-sur-Saint-Laurent,Québec,Canada /Meteo/Villes/can/Pages/CAQC0138.htm
		{Deschambault Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0579.htm
		Deseronto,Ontario,Canada /Meteo/Villes/can/Pages/CAON0181.htm
		{Destruction Bay,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0006.htm
		Deux-Montagnes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0139.htm
		Deux-Rivières,Ontario,Canada /Meteo/Villes/can/Pages/CAON0183.htm
		Devlin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0184.htm
		Devon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0091.htm
		Dewberry,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0665.htm
		Didsbury,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0092.htm
		Dieppe,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0033.htm
		Digby,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0038.htm
		Dillon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0080.htm
		Dingwall,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0039.htm
		Dinsmore,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0081.htm
		Disraeli,Québec,Canada /Meteo/Villes/can/Pages/CAQC0140.htm
		Dixonville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0093.htm
		Doaktown,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0034.htm
		Dodsland,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0082.htm
		{Dokis First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1563.htm
		Dokis,Ontario,Canada /Meteo/Villes/can/Pages/CAON0185.htm
		Dolbeau-Mistassini,Québec,Canada /Meteo/Villes/can/Pages/CAQC0141.htm
		{Dollard-des-Ormeaux (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0142.htm
		{Dominion City,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0048.htm
		Domremy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0083.htm
		Donalda,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0094.htm
		Donald,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0080.htm
		Donnacona,Québec,Canada /Meteo/Villes/can/Pages/CAQC0143.htm
		Donnelly,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0095.htm
		Dorchester,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0035.htm
		Dorchester,Ontario,Canada /Meteo/Villes/can/Pages/CAON0186.htm
		Dorion,Ontario,Canada /Meteo/Villes/can/Pages/CAON0187.htm
		Dorset,Ontario,Canada /Meteo/Villes/can/Pages/CAON0188.htm
		{Dorval (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0144.htm
		{Douglas Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0081.htm
		Douglastown,Ontario,Canada /Meteo/Villes/can/Pages/CAON1727.htm
		Douglas,Ontario,Canada /Meteo/Villes/can/Pages/CAON0189.htm
		{Dover,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0072.htm
		Drake,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0084.htm
		{Drayton Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0096.htm
		Drayton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0190.htm
		Dresden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0191.htm
		Drumbo,Ontario,Canada /Meteo/Villes/can/Pages/CAON0192.htm
		Drumheller,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0097.htm
		Drummondville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0145.htm
		Dryden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0193.htm
		Dublin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0194.htm
		Dubreuilville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0195.htm
		Dubuc,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0085.htm
		Duchess,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0098.htm
		{Duck Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0086.htm
		Dugald,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0050.htm
		Duncan,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0083.htm
		Dunchurch,Ontario,Canada /Meteo/Villes/can/Pages/CAON1728.htm
		Dundalk,Ontario,Canada /Meteo/Villes/can/Pages/CAON0196.htm
		Dundas,Ontario,Canada /Meteo/Villes/can/Pages/CAON0197.htm
		Dundee,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0040.htm
		Dundurn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0087.htm
		Dungannon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0198.htm
		Dunham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0147.htm
		Dunnville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0199.htm
		Dunsford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0200.htm
		Dunster,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0085.htm
		Duparquet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0148.htm
		Dupuy,Québec,Canada /Meteo/Villes/can/Pages/CAQC0149.htm
		Durham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0201.htm
		Dutton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0202.htm
		Duvernay,Québec,Canada /Meteo/Villes/can/Pages/CAQC1197.htm
		Dwight,Ontario,Canada /Meteo/Villes/can/Pages/CAON0203.htm
		{Dyer's Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0204.htm
		Dysart,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0088.htm
		{Eagle Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1497.htm
		{Eagle River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0205.htm
		Eaglesham,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0099.htm
		{Ear Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0206.htm
		{Earl Grey,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0089.htm
		Earlton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0207.htm
		{East Angus,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0150.htm
		{East Bay,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0041.htm
		{East Broughton,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0151.htm
		{East Coulee,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0100.htm
		{East Farnham,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0152.htm
		{East Gwillimbury,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0208.htm
		{East Hereford,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0153.htm
		{East Pine,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0086.htm
		{East Point,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0030.htm
		{East York,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0209.htm
		Eastend,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0090.htm
		Easterville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0051.htm
		Eastmain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0154.htm
		Eastman,Québec,Canada /Meteo/Villes/can/Pages/CAQC0155.htm
		{Eastport,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0073.htm
		Eastwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0210.htm
		{Eaton (Sawyerville),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0478.htm
		Eatonia,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0091.htm
		{Echo Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0211.htm
		Eckville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0101.htm
		{Ecum Secum,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0042.htm
		Edam,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0092.htm
		Eddystone,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0052.htm
		Edgerton,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0102.htm
		Edmonton,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0103.htm
		Edmundston,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0036.htm
		Edson,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0104.htm
		Edwin,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0054.htm
		{Edzo,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0004.htm
		Eganville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0212.htm
		Elbow,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0093.htm
		Eldon,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0009.htm
		Elfros,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0094.htm
		Elgin,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0055.htm
		Elgin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0213.htm
		Elie,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0056.htm
		Elizabethtown,Ontario,Canada /Meteo/Villes/can/Pages/CAON1729.htm
		{Elk Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0214.htm
		{Elk Point,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0105.htm
		Elkford,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0087.htm
		Elkhorn,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0057.htm
		Elko,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0088.htm
		Elkwater,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0106.htm
		{Elliot Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0215.htm
		{Elliston,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0074.htm
		{Elm Creek,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0058.htm
		Elmira,Ontario,Canada /Meteo/Villes/can/Pages/CAON0216.htm
		Elmsdale,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0043.htm
		Elmvale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0217.htm
		Elnora,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0107.htm
		Elora,Ontario,Canada /Meteo/Villes/can/Pages/CAON0218.htm
		Elrose,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0095.htm
		{Embree,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0075.htm
		Embro,Ontario,Canada /Meteo/Villes/can/Pages/CAON0219.htm
		Embrun,Ontario,Canada /Meteo/Villes/can/Pages/CAON0220.htm
		Emerson,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0060.htm
		Emeryville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0221.htm
		Emo,Ontario,Canada /Meteo/Villes/can/Pages/CAON0222.htm
		Empress,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0108.htm
		Emsdale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0223.htm
		Enchant,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0109.htm
		Enderby,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0089.htm
		{Englee,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0076.htm
		Englehart,Ontario,Canada /Meteo/Villes/can/Pages/CAON0224.htm
		{English Harbour East,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0077.htm
		Enterprise,Ontario,Canada /Meteo/Villes/can/Pages/CAON0225.htm
		{Enterprise,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0005.htm
		Entrelacs,Québec,Canada /Meteo/Villes/can/Pages/CAQC0156.htm
		Erickson,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0061.htm
		Eriksdale,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0062.htm
		Erin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0226.htm
		Eskasoni,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0044.htm
		Espanola,Ontario,Canada /Meteo/Villes/can/Pages/CAON0227.htm
		Essex,Ontario,Canada /Meteo/Villes/can/Pages/CAON0228.htm
		Estaire,Ontario,Canada /Meteo/Villes/can/Pages/CAON0229.htm
		Esterhazy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0096.htm
		{Estevan Point,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0090.htm
		Estevan,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0097.htm
		Eston,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0098.htm
		Ethelbert,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0063.htm
		Etobicoke,Ontario,Canada /Meteo/Villes/can/Pages/CAON0230.htm
		Etzikom,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0110.htm
		Eugenia,Ontario,Canada /Meteo/Villes/can/Pages/CAON1760.htm
		Évain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0159.htm
		Evansburg,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0111.htm
		Exeter,Ontario,Canada /Meteo/Villes/can/Pages/CAON0231.htm
		Exshaw,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0112.htm
		Eyebrow,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0099.htm
		Fabreville,Québec,Canada /Meteo/Villes/can/Pages/CAQC1201.htm
		Fabre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0160.htm
		{Fair Haven,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0079.htm
		{Fairmont Hot Springs,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0091.htm
		Fairview,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0113.htm
		Falardeau,Québec,Canada /Meteo/Villes/can/Pages/CAQC1198.htm
		{Falcon Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0064.htm
		Falher,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0114.htm
		Falkland,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0092.htm
		Farnham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0161.htm
		Faro,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0008.htm
		Fassett,Québec,Canada /Meteo/Villes/can/Pages/CAQC1199.htm
		Fauquier,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0093.htm
		Fauquier,Ontario,Canada /Meteo/Villes/can/Pages/CAON0232.htm
		Faust,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0115.htm
		{Fenelon Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0233.htm
		Fenwick,Ontario,Canada /Meteo/Villes/can/Pages/CAON0234.htm
		Fergus,Ontario,Canada /Meteo/Villes/can/Pages/CAON0235.htm
		Ferintosh,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0116.htm
		Ferland,Québec,Canada /Meteo/Villes/can/Pages/CAQC0162.htm
		Ferme-Neuve,Québec,Canada /Meteo/Villes/can/Pages/CAQC0163.htm
		{Fermeuse,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0081.htm
		Fermont,Québec,Canada /Meteo/Villes/can/Pages/CAQC0164.htm
		Fernie,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0094.htm
		Feversham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0236.htm
		Field,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0095.htm
		Field,Ontario,Canada /Meteo/Villes/can/Pages/CAON0237.htm
		Fillmore,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0100.htm
		Finch,Ontario,Canada /Meteo/Villes/can/Pages/CAON0238.htm
		Fingal,Ontario,Canada /Meteo/Villes/can/Pages/CAON0239.htm
		{Fisher Branch,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0065.htm
		{Fisher River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0066.htm
		Fisherville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0240.htm
		Flamborough,Ontario,Canada /Meteo/Villes/can/Pages/CAON0241.htm
		Flanders,Ontario,Canada /Meteo/Villes/can/Pages/CAON0242.htm
		Flatbush,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0117.htm
		Flatrock,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0096.htm
		{Flatrock,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0082.htm
		Fleming,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0101.htm
		Flesherton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0243.htm
		{Fleur de Lys,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0083.htm
		{Fleurimont (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0165.htm
		{Flin Flon,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0067.htm
		Florenceville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0037.htm
		{Flower's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0084.htm
		{Foam Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0102.htm
		{Fogo,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0085.htm
		Foleyet,Ontario,Canada /Meteo/Villes/can/Pages/CAON0244.htm
		Foley,Ontario,Canada /Meteo/Villes/can/Pages/CAON1730.htm
		Fond-du-Lac,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0103.htm
		{Fords Mills,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0038.htm
		Foremost,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0118.htm
		{Forest Grove,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0097.htm
		Forestburg,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0119.htm
		Forestville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0166.htm
		Forest,Ontario,Canada /Meteo/Villes/can/Pages/CAON0245.htm
		{Fork River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0068.htm
		{Fort Albany,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0246.htm
		{Fort Assiniboine,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0120.htm
		{Fort Chipewyan,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0121.htm
		{Fort Erie,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0247.htm
		{Fort Frances,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0248.htm
		{Fort Fraser,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0098.htm
		{Fort Good Hope,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0006.htm
		{Fort Hope,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0249.htm
		{Fort Liard,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0007.htm
		{Fort MacKay,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0122.htm
		{Fort Macleod,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0123.htm
		{Fort McMurray,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0124.htm
		{Fort McPherson,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0008.htm
		{Fort Nelson,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0100.htm
		{Fort Providence,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0009.htm
		{Fort Qu Appelle,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0104.htm
		{Fort Saskatchewan,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0125.htm
		{Fort Severn First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1585.htm
		{Fort Severn,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0250.htm
		{Fort Simpson,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0011.htm
		{Fort Smith,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0012.htm
		{Fort St James,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0101.htm
		{Fort St John,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0102.htm
		{Fort Vermilion,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0126.htm
		{Fort William First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1508.htm
		Fort-Coulonge,Québec,Canada /Meteo/Villes/can/Pages/CAQC0168.htm
		{Forteau,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0086.htm
		Fortierville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0169.htm
		{Fortune,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0087.htm
		Fossambault-sur-le-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0170.htm
		{Fox Cove-Mortier,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0088.htm
		{Fox Creek,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0127.htm
		{Fox Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0128.htm
		{Fox Valley,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0105.htm
		Foxboro,Ontario,Canada /Meteo/Villes/can/Pages/CAON1731.htm
		Foxwarren,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0069.htm
		Foymount,Ontario,Canada /Meteo/Villes/can/Pages/CAON0251.htm
		Frampton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0171.htm
		Francis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0106.htm
		{Francois,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANL0064.htm
		Frankford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0252.htm
		{Franklin Centre,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0172.htm
		{Fraser Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0105.htm
		{Fredericton Junction,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0041.htm
		Fredericton,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0040.htm
		Freelton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0253.htm
		Freeport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0045.htm
		Frelighsburg,Québec,Canada /Meteo/Villes/can/Pages/CAQC0173.htm
		{French River First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1476.htm
		{French Village,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0046.htm
		{Frenchmans Island,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0091.htm
		{Freshwater,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0092.htm
		Frobisher,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0107.htm
		Frontier,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0108.htm
		Fruitvale,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0106.htm
		Fugereville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0174.htm
		Gabarus,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0047.htm
		Gabriola,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0108.htm
		Gadsby,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0129.htm
		Gagetown,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0042.htm
		Gainsborough,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0109.htm
		Galahad,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0130.htm
		{Galiano Island,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0109.htm
		Galt,Ontario,Canada /Meteo/Villes/can/Pages/CAON0254.htm
		{Gambo,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0093.htm
		Gananoque,Ontario,Canada /Meteo/Villes/can/Pages/CAON0255.htm
		{Gander,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0094.htm
		Ganges,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0110.htm
		{Garden Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANL0066.htm
		{Garden Hill,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0256.htm
		{Garden River First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1475.htm
		{Garnish,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0096.htm
		Garson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0257.htm
		Gaspé,Québec,Canada /Meteo/Villes/can/Pages/CAQC0176.htm
		Gatineau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0177.htm
		{Gaultois,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0097.htm
		Gentilly,Québec,Canada /Meteo/Villes/can/Pages/CAQC0178.htm
		Georgetown,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0010.htm
		Georgetown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0258.htm
		Georgina,Ontario,Canada /Meteo/Villes/can/Pages/CAON0259.htm
		Geraldton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0260.htm
		Gibbons,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0131.htm
		Gibsons,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0113.htm
		{Gift Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0132.htm
		{Gilbert Plains,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0072.htm
		Gillam,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0073.htm
		Gilmour,Ontario,Canada /Meteo/Villes/can/Pages/CAON0261.htm
		Gimli,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0074.htm
		Girardville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0179.htm
		Girouxville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0133.htm
		Giscome,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0114.htm
		{Gjoa Haven,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0010.htm
		{Glace Bay,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0048.htm
		Gladstone,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0075.htm
		Glaslyn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0110.htm
		Glassville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0043.htm
		Gleichen,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0134.htm
		{Glen Ewen,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0111.htm
		{Glen Robertson,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0262.htm
		{Glen Water,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0263.htm
		{Glen Williams,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1732.htm
		Glenavon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0112.htm
		Glenboro,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0076.htm
		Glencoe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0264.htm
		Glendon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0135.htm
		Glenella,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0077.htm
		Glenwood,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0136.htm
		{Glenwood,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0098.htm
		Gloucester,Ontario,Canada /Meteo/Villes/can/Pages/CAON0265.htm
		{Glovertown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0099.htm
		Godbout,Québec,Canada /Meteo/Villes/can/Pages/CAQC0180.htm
		Goderich,Ontario,Canada /Meteo/Villes/can/Pages/CAON0266.htm
		{Gods Lake Narrows,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0078.htm
		Gogama,Ontario,Canada /Meteo/Villes/can/Pages/CAON0267.htm
		{Gold Bridge,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0116.htm
		{Gold River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0117.htm
		Goldboro,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0049.htm
		{Golden Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0268.htm
		Golden,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0119.htm
		{Good Hope Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0120.htm
		Gooderham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0269.htm
		Goodeve,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0113.htm
		Goodsoil,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0114.htm
		{Goosebay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0100.htm
		{Gore Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0270.htm
		Gormley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0271.htm
		Gorrie,Ontario,Canada /Meteo/Villes/can/Pages/CAON0272.htm
		Goshen,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0050.htm
		{Goulais River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0273.htm
		Govan,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0115.htm
		Gowganda,Ontario,Canada /Meteo/Villes/can/Pages/CAON0274.htm
		Gracefield,Québec,Canada /Meteo/Villes/can/Pages/CAQC0181.htm
		Grafton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0275.htm
		Granby,Québec,Canada /Meteo/Villes/can/Pages/CAQC0182.htm
		{Grand Bank,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0101.htm
		{Grand Bay-Westfield,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0045.htm
		{Grand Beach,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0081.htm
		{Grand Bend,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0276.htm
		{Grand Centre,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0138.htm
		{Grand Etang,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0051.htm
		{Grand Falls-Windsor,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0104.htm
		{Grand Falls,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0046.htm
		{Grand Falls,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0103.htm
		{Grand Forks,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0121.htm
		{Grand Lake,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0052.htm
		{Grand Manan,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0047.htm
		{Grand Narrows,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0053.htm
		{Grand Rapids,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0082.htm
		{Grand Valley,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0277.htm
		{Grand-Mère (Shawinigan),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0184.htm
		Grand-Remous,Québec,Canada /Meteo/Villes/can/Pages/CAQC0185.htm
		Grand-Sault,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0048.htm
		{Grande Cache,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0139.htm
		{Grande Prairie,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0140.htm
		Grande-Anse,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0049.htm
		Grande-Entrée,Québec,Canada /Meteo/Villes/can/Pages/CAQC0186.htm
		Grande-Rivière,Québec,Canada /Meteo/Villes/can/Pages/CAQC0189.htm
		Grande-Vallée,Québec,Canada /Meteo/Villes/can/Pages/CAQC0190.htm
		Grandes-Bergeronnes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0191.htm
		Grandes-Piles,Québec,Canada /Meteo/Villes/can/Pages/CAQC0192.htm
		Grandview,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0083.htm
		Granisle,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0122.htm
		Granton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0278.htm
		Granum,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0141.htm
		Grasmere,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0123.htm
		Grassland,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0142.htm
		{Grassy Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0143.htm
		{Grassy Narrows First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1506.htm
		{Grassy Narrows,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0279.htm
		{Grassy Plains,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0124.htm
		Gravelbourg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0116.htm
		Gravenhurst,Ontario,Canada /Meteo/Villes/can/Pages/CAON0280.htm
		Grayson,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0117.htm
		{Great Harbour Deep,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0106.htm
		{Great Village,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0054.htm
		{Green Island Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0107.htm
		{Green Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0118.htm
		{Greenfield Park (Longueuil),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0193.htm
		{Greenspond,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0108.htm
		Greensville,Ontario,Canada /Meteo/Villes/can/Pages/CAON1733.htm
		Greenville,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0125.htm
		Greenwood,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0126.htm
		Greenwood,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0055.htm
		Grenfell,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0119.htm
		Grenville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0194.htm
		Gretna,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0084.htm
		Grimsby,Ontario,Canada /Meteo/Villes/can/Pages/CAON0281.htm
		Grimshaw,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0144.htm
		Grouard,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0145.htm
		Guelph,Ontario,Canada /Meteo/Villes/can/Pages/CAON0282.htm
		Guigues,Québec,Canada /Meteo/Villes/can/Pages/CAQC0195.htm
		{Gull Bay First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1569.htm
		{Gull Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0283.htm
		{Gull Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0120.htm
		Guysborough,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0056.htm
		Gypsumville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0087.htm
		Hadashville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0088.htm
		Hafford,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0121.htm
		Hagersville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0284.htm
		Hague,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0122.htm
		Haileybury,Ontario,Canada /Meteo/Villes/can/Pages/CAON0285.htm
		{Haines Junction,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0009.htm
		{Hairy Hill,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0146.htm
		Haldimand,Ontario,Canada /Meteo/Villes/can/Pages/CAON0286.htm
		Haliburton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0287.htm
		Halifax,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0057.htm
		Halkirk,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0147.htm
		{Halton Hills,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0288.htm
		Ham-Nord,Québec,Canada /Meteo/Villes/can/Pages/CAQC0197.htm
		Hamilton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0289.htm
		Hamiota,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0089.htm
		Hammond,Québec,Canada /Meteo/Villes/can/Pages/CAQC1200.htm
		{Hampden,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0111.htm
		{Hampstead (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0198.htm
		Hampstead,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0050.htm
		Hampton,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0051.htm
		Hampton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0290.htm
		Hanley,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0123.htm
		Hanmer,Ontario,Canada /Meteo/Villes/can/Pages/CAON0291.htm
		Hanna,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0148.htm
		Hanover,Ontario,Canada /Meteo/Villes/can/Pages/CAON0292.htm
		{Hant's Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0112.htm
		Hantsport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0058.htm
		{Happy Valley-Goose Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0113.htm
		{Harbour Breton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0114.htm
		{Harbour Grace,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0115.htm
		{Harbour Main-Chapel Cove-Lakeview,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0116.htm
		Hardisty,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0149.htm
		{Hare Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0117.htm
		Harewood,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0198.htm
		Harrietsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0293.htm
		{Harrington Harbour,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0199.htm
		Harriston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0294.htm
		Harris,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0124.htm
		Harrowsmith,Ontario,Canada /Meteo/Villes/can/Pages/CAON0296.htm
		Harrow,Ontario,Canada /Meteo/Villes/can/Pages/CAON0295.htm
		Hartland,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0052.htm
		{Hartley Bay,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0130.htm
		Hartney,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0090.htm
		Hastings,Ontario,Canada /Meteo/Villes/can/Pages/CAON0297.htm
		Havelock,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0054.htm
		Havelock,Ontario,Canada /Meteo/Villes/can/Pages/CAON0298.htm
		Havre-Aubert,Québec,Canada /Meteo/Villes/can/Pages/CAQC0201.htm
		Havre-Saint-Pierre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0203.htm
		Havre-aux-Maisons,Québec,Canada /Meteo/Villes/can/Pages/CAQC0202.htm
		Hawarden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0125.htm
		{Hawk Junction,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0299.htm
		{Hawke's Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0119.htm
		Hawkesbury,Ontario,Canada /Meteo/Villes/can/Pages/CAON0300.htm
		{Hay Lakes,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0150.htm
		{Hay River,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0013.htm
		Hays,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0151.htm
		Hazelton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0132.htm
		Hazlet,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0126.htm
		Hearst,Ontario,Canada /Meteo/Villes/can/Pages/CAON0301.htm
		{Heart's Content,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0120.htm
		{Heart's Delight-Islington,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0121.htm
		{Heart's Desire,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0122.htm
		Heatherton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0060.htm
		Hébertville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0204.htm
		Hébertville-Station,Québec,Canada /Meteo/Villes/can/Pages/CAQC0205.htm
		Hecla,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0092.htm
		Hedley,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0133.htm
		Heinsburg,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0152.htm
		Heisler,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0153.htm
		{Hemlock Valley,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0134.htm
		Hemlo,Ontario,Canada /Meteo/Villes/can/Pages/CAON0302.htm
		Hemmingford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0206.htm
		{Hendrix Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0135.htm
		Henryville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0207.htm
		Hensall,Ontario,Canada /Meteo/Villes/can/Pages/CAON0303.htm
		{Henvey Inlet First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1483.htm
		Hepburn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0127.htm
		Hepworth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0304.htm
		Herbert,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0128.htm
		Herschel,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0129.htm
		Hespeler,Ontario,Canada /Meteo/Villes/can/Pages/CAON0305.htm
		{Hickman's Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0124.htm
		Hickson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0306.htm
		{High Level,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0154.htm
		{High Prairie,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0155.htm
		{High River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0156.htm
		Highgate,Ontario,Canada /Meteo/Villes/can/Pages/CAON0307.htm
		Hilda,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0157.htm
		{Hillgrade,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0125.htm
		Hillsborough,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0055.htm
		Hillsburgh,Ontario,Canada /Meteo/Villes/can/Pages/CAON0308.htm
		{Hillview,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0126.htm
		{Hines Creek,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0158.htm
		Hinton,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0159.htm
		Hixon,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0136.htm
		Hobbema,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0160.htm
		Hodgeville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0130.htm
		Holberg,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0137.htm
		Holden,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0161.htm
		Holdfast,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0131.htm
		{Holland Landing,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0309.htm
		Holland,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0093.htm
		Holstein,Ontario,Canada /Meteo/Villes/can/Pages/CAON0310.htm
		{Holyrood,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0127.htm
		{Honey Harbour,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0311.htm
		{Hopedale,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0128.htm
		Hopewell,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0061.htm
		Hope,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0138.htm
		Hornepayne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0312.htm
		Horsefly,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0139.htm
		Houston,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0140.htm
		Howick,Québec,Canada /Meteo/Villes/can/Pages/CAQC0210.htm
		{Howley,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0130.htm
		Hoyt,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0056.htm
		Hubbards,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0062.htm
		{Hudson Bay,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0132.htm
		{Hudson's Hope,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0141.htm
		Hudson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0313.htm
		Hudson,Québec,Canada /Meteo/Villes/can/Pages/CAQC0211.htm
		Hughenden,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0162.htm
		{Hull (Gatineau),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0212.htm
		{Humber Arm South,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0131.htm
		Humboldt,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0133.htm
		Humphrey,Ontario,Canada /Meteo/Villes/can/Pages/CAON1734.htm
		{Hunter River,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0011.htm
		Huntingdon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0213.htm
		Huntsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0314.htm
		Hussar,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0163.htm
		Hythe,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0164.htm
		Iberville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0214.htm
		Ignace,Ontario,Canada /Meteo/Villes/can/Pages/CAON0315.htm
		Ilderton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0316.htm
		Île-à-la-Crosse,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0134.htm
		Île-aux-Coudres,Québec,Canada /Meteo/Villes/can/Pages/CAQC0215.htm
		{Îles-de-la-Madeleine (Cap-aux-Meules),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0078.htm
		Îles-de-la-Madeleine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0217.htm
		Ilford,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0094.htm
		Imperial,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0135.htm
		{Indian Head,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0136.htm
		{Indian Tickle,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0132.htm
		Ingersoll,Ontario,Canada /Meteo/Villes/can/Pages/CAON0317.htm
		Ingleside,Ontario,Canada /Meteo/Villes/can/Pages/CAON0318.htm
		Ingonish,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0063.htm
		Innerkip,Ontario,Canada /Meteo/Villes/can/Pages/CAON0319.htm
		Innisfail,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0165.htm
		Innisfil,Ontario,Canada /Meteo/Villes/can/Pages/CAON0320.htm
		Innisfree,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0166.htm
		Inukjuak,Québec,Canada /Meteo/Villes/can/Pages/CAQC0218.htm
		{Inuvik,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0015.htm
		Inverary,Ontario,Canada /Meteo/Villes/can/Pages/CAON0321.htm
		Invermay,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0137.htm
		Invermere,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0142.htm
		Inverness,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0064.htm
		Inverness,Québec,Canada /Meteo/Villes/can/Pages/CAQC0219.htm
		Inwood,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0096.htm
		Inwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0322.htm
		Iqaluit,Nunavut,Canada /Meteo/Villes/can/Pages/CANU0014.htm
		Irma,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0167.htm
		{Iron Bridge,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0323.htm
		{Iron Springs,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0168.htm
		{Iroquois Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0325.htm
		Iroquois,Ontario,Canada /Meteo/Villes/can/Pages/CAON0324.htm
		Irricana,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0169.htm
		Irvine,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0170.htm
		Iskut,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0143.htm
		{Island Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0133.htm
		{Island Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0097.htm
		Islay,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0171.htm
		{Isle aux Morts,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0134.htm
		Ituna,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0138.htm
		{Jackson's Arm,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0135.htm
		{Jacquet River,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0196.htm
		{Jaffray Melick,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0326.htm
		Jaffray,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0144.htm
		{Jamestown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0136.htm
		Jansen,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0139.htm
		Jarvie,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0172.htm
		Jarvis,Ontario,Canada /Meteo/Villes/can/Pages/CAON0327.htm
		Jasper,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0173.htm
		Jasper,Ontario,Canada /Meteo/Villes/can/Pages/CAON1735.htm
		{Jean Marie River,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0016.htm
		Jellicoe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0328.htm
		Jenner,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0175.htm
		Jockvale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0329.htm
		{Joe Batt's Arm-Barr'd Islands-Shoal Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0138.htm
		Joggins,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0309.htm
		Johnstown,Ontario,Canada /Meteo/Villes/can/Pages/CAON1753.htm
		Joliette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0221.htm
		{Jonquière (Saguenay),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0222.htm
		Jordan,Ontario,Canada /Meteo/Villes/can/Pages/CAON1736.htm
		Joussard,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0176.htm
		Joutel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0223.htm
		{Kakisa,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0017.htm
		Kaministiquia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0330.htm
		Kamiskotia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0331.htm
		Kamloops,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0146.htm
		Kamsack,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0140.htm
		Kananaskis,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0177.htm
		Kanata,Ontario,Canada /Meteo/Villes/can/Pages/CAON0332.htm
		Kangiqsualujjuaq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0224.htm
		Kangirsuk,Québec,Canada /Meteo/Villes/can/Pages/CAQC0226.htm
		Kapuskasing,Ontario,Canada /Meteo/Villes/can/Pages/CAON0333.htm
		{Kasabonika First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1502.htm
		{Kashechewan First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1564.htm
		Kaslo,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0147.htm
		Kateville,Québec,Canada /Meteo/Villes/can/Pages/CAQC1202.htm
		Kazabazua,Québec,Canada /Meteo/Villes/can/Pages/CAQC0227.htm
		Kearney,Ontario,Canada /Meteo/Villes/can/Pages/CAON0336.htm
		Kedgwick,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0057.htm
		Keene,Ontario,Canada /Meteo/Villes/can/Pages/CAON0337.htm
		Keephills,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0178.htm
		Keewatin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0338.htm
		{Keg River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0179.htm
		Kelliher,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0141.htm
		Kelowna,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0149.htm
		Kelvington,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0142.htm
		Kelwood,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0099.htm
		Kemano,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0150.htm
		Kemptville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0339.htm
		Kenaston,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0143.htm
		Kennedy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0144.htm
		Kennetcook,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0066.htm
		Kenora,Ontario,Canada /Meteo/Villes/can/Pages/CAON0340.htm
		Kenosee,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0145.htm
		Kensington,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0012.htm
		{Kent Centre,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1619.htm
		Kenton,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0100.htm
		Kentville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0067.htm
		Kenzieville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0068.htm
		Keremeos,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0151.htm
		Kerrobert,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0146.htm
		Kerwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0341.htm
		Keswick,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0058.htm
		Keswick,Ontario,Canada /Meteo/Villes/can/Pages/CAON0342.htm
		{Ketch Harbour,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0069.htm
		{Key Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0364.htm
		Killaloe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0343.htm
		Killam,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0180.htm
		Killarney,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0101.htm
		Killarney,Ontario,Canada /Meteo/Villes/can/Pages/CAON0344.htm
		Kimberley,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0152.htm
		Kincaid,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0147.htm
		Kincardine,Ontario,Canada /Meteo/Villes/can/Pages/CAON0345.htm
		Kincolith,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0153.htm
		Kindersley,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0148.htm
		{King City,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0346.htm
		{King's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0139.htm
		{King's Point,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0140.htm
		{Kingfisher Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1499.htm
		{Kingfisher Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0348.htm
		Kingsbury,Québec,Canada /Meteo/Villes/can/Pages/CAQC0228.htm
		{Kingsey Falls,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0229.htm
		Kingston,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0070.htm
		Kingston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0349.htm
		Kingsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0350.htm
		Kinistino,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0149.htm
		Kinmount,Ontario,Canada /Meteo/Villes/can/Pages/CAON0351.htm
		{Kinnear's Mills,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1342.htm
		Kintore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0352.htm
		Kinuso,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0181.htm
		Kipling,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0150.htm
		{Kippens,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0141.htm
		Kirkfield,Ontario,Canada /Meteo/Villes/can/Pages/CAON0353.htm
		{Kirkland (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0230.htm
		{Kirkland Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0354.htm
		Kirkton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0355.htm
		Kisbey,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0151.htm
		Kitchener,Ontario,Canada /Meteo/Villes/can/Pages/CAON0356.htm
		Kitimat,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0154.htm
		Kitkatla,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0155.htm
		Kitsault,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0156.htm
		Kitscoty,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0182.htm
		Kitwanga,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0157.htm
		Kleinburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0357.htm
		Klemtu,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0158.htm
		Klock,Ontario,Canada /Meteo/Villes/can/Pages/CAON1977.htm
		Knowlton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0231.htm
		Kuujjuaq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0232.htm
		Kyle,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0152.htm
		Kyuquot,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0160.htm
		L'Acadie,Québec,Canada /Meteo/Villes/can/Pages/CAQC1203.htm
		{L'Ancienne-Lorette (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0233.htm
		L'Ange-Gardien,Québec,Canada /Meteo/Villes/can/Pages/CAQC0234.htm
		L'Annonciation,Québec,Canada /Meteo/Villes/can/Pages/CAQC0235.htm
		{L'Anse-au-Loup,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0142.htm
		L'Ardoise,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0071.htm
		L'Assomption,Québec,Canada /Meteo/Villes/can/Pages/CAQC0236.htm
		L'Avenir,Québec,Canada /Meteo/Villes/can/Pages/CAQC0237.htm
		L'Épiphanie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0238.htm
		L'Ile-Aux-Noix,Québec,Canada /Meteo/Villes/can/Pages/CAQC1204.htm
		{L'Île-Bizard (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0239.htm
		L'Île-Cadieux,Québec,Canada /Meteo/Villes/can/Pages/CAQC0240.htm
		{L'Île-Dorval (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0242.htm
		L'Île-Perrot,Québec,Canada /Meteo/Villes/can/Pages/CAQC0243.htm
		L'Île-Verte,Québec,Canada /Meteo/Villes/can/Pages/CAQC0244.htm
		L'Île-d'Entrée,Québec,Canada /Meteo/Villes/can/Pages/CAQC0241.htm
		L'Islet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0245.htm
		L'Orignal,Ontario,Canada /Meteo/Villes/can/Pages/CAON0358.htm
		{L'aéroport de Kugluktuk,Nunavut,Canada} /Meteo/Villes/can/Pages/CANT0018.htm
		{La Baie (Saguenay),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0246.htm
		{La Broquerie,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0103.htm
		{La Corne,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0247.htm
		{La Crête,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0183.htm
		{La Doré,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0248.htm
		{La Grande-Quatre,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1015.htm
		{La Grande,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0249.htm
		{La Guadeloupe,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0250.htm
		{La Loche,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0153.htm
		{La Malbaie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0251.htm
		{La Martre,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0252.htm
		{La Minerve,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0253.htm
		{La Patrie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0254.htm
		{La Pocatière,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0256.htm
		{La Prairie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0257.htm
		{La Reine,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0258.htm
		{La Romaine,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0259.htm
		{La Ronge,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0154.htm
		{La Sarre,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0260.htm
		{La Scie,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0144.htm
		{La Tuque,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0261.htm
		LaHave,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0072.htm
		{LaSalle (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0289.htm
		LaSalle,Ontario,Canada /Meteo/Villes/can/Pages/CAON0370.htm
		Labelle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0263.htm
		{Labrador City,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0145.htm
		{Lac Brochet,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0104.htm
		{Lac Kenogami,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1205.htm
		{Lac La Biche,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0185.htm
		{Lac Seul First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1524.htm
		{Lac du Bonnet,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0105.htm
		{Lac la Croix,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0359.htm
		{Lac la Hache,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0161.htm
		Lac-Bouchette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0266.htm
		Lac-Brome,Québec,Canada /Meteo/Villes/can/Pages/CAQC0267.htm
		Lac-Delage,Québec,Canada /Meteo/Villes/can/Pages/CAQC0268.htm
		Lac-Drolet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0270.htm
		Lac-Édouard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0272.htm
		Lac-Etchemin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0273.htm
		Lac-Frontière,Québec,Canada /Meteo/Villes/can/Pages/CAQC0274.htm
		Lac-Mégantic,Québec,Canada /Meteo/Villes/can/Pages/CAQC0275.htm
		Lac-Poulin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0276.htm
		Lac-Saguay,Québec,Canada /Meteo/Villes/can/Pages/CAQC0277.htm
		Lac-Saint-Charles,Québec,Canada /Meteo/Villes/can/Pages/CAQC1089.htm
		Lac-Saint-Joseph,Québec,Canada /Meteo/Villes/can/Pages/CAQC0279.htm
		Lac-Sergent,Québec,Canada /Meteo/Villes/can/Pages/CAQC0278.htm
		Lac-au-Saumon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0264.htm
		Lac-aux-Sables,Québec,Canada /Meteo/Villes/can/Pages/CAQC0265.htm
		Lac-des-Écorces,Québec,Canada /Meteo/Villes/can/Pages/CAQC0269.htm
		Lac-du-Cerf,Québec,Canada /Meteo/Villes/can/Pages/CAQC0271.htm
		{Lachine (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0281.htm
		Lachute,Québec,Canada /Meteo/Villes/can/Pages/CAQC0282.htm
		Lacolle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0283.htm
		Lacombe,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0186.htm
		{Ladle Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0146.htm
		Ladysmith,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0163.htm
		Lafleche,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0155.htm
		{Lafontaine (Saint-Jérôme),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0284.htm
		Lafontaine,Ontario,Canada /Meteo/Villes/can/Pages/CAON0360.htm
		{Lagoon City,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0361.htm
		Laird,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0156.htm
		{Lake Alma,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0157.htm
		{Lake Charlotte,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0073.htm
		{Lake Cowichan,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0164.htm
		{Lake Lenore,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0158.htm
		{Lake Louise,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0187.htm
		Lakefield,Ontario,Canada /Meteo/Villes/can/Pages/CAON0362.htm
		{Lamaline,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0147.htm
		Lambeth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0363.htm
		{Lambton Shores,Ontario,Canada} /Meteo/Villes/can/Pages/CAON2021.htm
		Lambton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0286.htm
		Lamèque,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0059.htm
		Lamont,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0188.htm
		Lampman,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0159.htm
		Lanark,Ontario,Canada /Meteo/Villes/can/Pages/CAON0364.htm
		Lancaster,Ontario,Canada /Meteo/Villes/can/Pages/CAON0365.htm
		Landis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0160.htm
		Langara,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0167.htm
		Langdon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0189.htm
		Langenburg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0162.htm
		Langham,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0163.htm
		Langley,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0168.htm
		Langruth,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0107.htm
		Langton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0366.htm
		Lang,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0161.htm
		Lanigan,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0164.htm
		Lanoraie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0287.htm
		{Lansdowne House,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0368.htm
		Lansdowne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0367.htm
		Lantzville,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0169.htm
		{Larder Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0369.htm
		{Lark Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0148.htm
		{Larrys River,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0075.htm
		Lashburn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0165.htm
		Latchford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0371.htm
		{Laterrière (Saguenay),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0290.htm
		Latulipe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0291.htm
		Laurentides,Québec,Canada /Meteo/Villes/can/Pages/CAQC0292.htm
		Laurier-Station,Québec,Canada /Meteo/Villes/can/Pages/CAQC0293.htm
		Laurierville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0294.htm
		{Laval Ouest,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1207.htm
		{Laval des Rapides,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1206.htm
		Lavaltrie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0296.htm
		Laval,Québec,Canada /Meteo/Villes/can/Pages/CAQC0295.htm
		Laverlochère,Québec,Canada /Meteo/Villes/can/Pages/CAQC0297.htm
		Lavoy,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0190.htm
		{Lawn,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0149.htm
		Lawrencetown,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0076.htm
		Lawrenceville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0298.htm
		{Le Bic,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0299.htm
		{Le Gardeur,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0300.htm
		{LeMoyne (Longueuil),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0304.htm
		Leader,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0166.htm
		{Leaf Rapids,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0108.htm
		Leamington,Ontario,Canada /Meteo/Villes/can/Pages/CAON0372.htm
		Leask,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0167.htm
		Lebel-sur-Quevillon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0301.htm
		Leclercville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0302.htm
		Leduc,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0191.htm
		Lefroy,Ontario,Canada /Meteo/Villes/can/Pages/CAON0373.htm
		Legal,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0192.htm
		Lemberg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0168.htm
		{Lennoxville (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0305.htm
		Leoville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0169.htm
		Leroy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0170.htm
		Léry,Québec,Canada /Meteo/Villes/can/Pages/CAQC0306.htm
		{Les Boules,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0307.htm
		{Les Cèdres,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0308.htm
		{Les Coteaux,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1208.htm
		{Les Éboulements,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0309.htm
		{Les Escoumins,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0310.htm
		{Les Méchins,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0311.htm
		Leslieville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0193.htm
		Lestock,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0171.htm
		Lethbridge,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0194.htm
		Levack,Ontario,Canada /Meteo/Villes/can/Pages/CAON0374.htm
		Lévis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0312.htm
		{Lewisporte,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0151.htm
		Libau,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0110.htm
		Liberty,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0172.htm
		Likely,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0171.htm
		Lillooet,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0172.htm
		Limerick,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0173.htm
		Lincoln,Ontario,Canada /Meteo/Villes/can/Pages/CAON0375.htm
		Lindsay,Ontario,Canada /Meteo/Villes/can/Pages/CAON0376.htm
		Lintlaw,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0174.htm
		Linwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0377.htm
		{Lion's Head,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0378.htm
		Lipton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0175.htm
		Listowel,Ontario,Canada /Meteo/Villes/can/Pages/CAON0379.htm
		{Little Bay Islands,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0153.htm
		{Little Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0152.htm
		{Little Britain,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0380.htm
		{Little Burnt Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0154.htm
		{Little Catalina,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0155.htm
		{Little Current,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0381.htm
		{Little Fort,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0173.htm
		{Little Grand Rapids,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0111.htm
		{Little Heart's Ease,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0157.htm
		Lively,Ontario,Canada /Meteo/Villes/can/Pages/CAON0382.htm
		Liverpool,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0078.htm
		Lloydminster,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0196.htm
		Lloydminster,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0176.htm
		Lockeport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0079.htm
		Lockport,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0112.htm
		Lodgepole,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0197.htm
		{Logan Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0174.htm
		{Logy Bay-Middle Cove-Outer Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0158.htm
		Lombardy,Ontario,Canada /Meteo/Villes/can/Pages/CAON1737.htm
		Lomond,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0198.htm
		London,Ontario,Canada /Meteo/Villes/can/Pages/CAON0383.htm
		{Long Harbour-Mount Arlington Heights,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0159.htm
		{Long Lac,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0384.htm
		{Long Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1495.htm
		{Long Point,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0385.htm
		{Long Pond,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0160.htm
		{Long Sault,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0386.htm
		Longlac,Ontario,Canada /Meteo/Villes/can/Pages/CAON0387.htm
		Longue-Rive,Québec,Canada /Meteo/Villes/can/Pages/CAQC0965.htm
		Longueuil,Québec,Canada /Meteo/Villes/can/Pages/CAQC0313.htm
		Longview,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0199.htm
		{Loon Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0177.htm
		Loos,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0175.htm
		Loreburn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0178.htm
		{Loretteville (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0314.htm
		Lorne,Ontario,Canada /Meteo/Villes/can/Pages/CAON1754.htm
		Lorraine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0315.htm
		Lorrainville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0316.htm
		Lougheed,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0200.htm
		Louisbourg,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0080.htm
		Louisdale,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0081.htm
		Louiseville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0317.htm
		Lourdes-de-Blanc-Sablon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0318.htm
		{Lourdes,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0161.htm
		Louvicourt,Québec,Canada /Meteo/Villes/can/Pages/CAQC0319.htm
		{Lower Island Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0162.htm
		{Lower Post,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0176.htm
		{Lower Sackville,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0310.htm
		Low,Québec,Canada /Meteo/Villes/can/Pages/CAQC0320.htm
		Lucan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0388.htm
		Lucknow,Ontario,Canada /Meteo/Villes/can/Pages/CAON0389.htm
		{Lucky Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0179.htm
		Lumby,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0177.htm
		Lumsden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0180.htm
		{Lumsden,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0163.htm
		Lundar,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0114.htm
		Lunenburg,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0082.htm
		Luseland,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0181.htm
		Luskville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0322.htm
		Lynden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0390.htm
		{Lynn Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0116.htm
		Lyn,Ontario,Canada /Meteo/Villes/can/Pages/CAON1755.htm
		Lyster,Québec,Canada /Meteo/Villes/can/Pages/CAQC0323.htm
		Lytton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0178.htm
		M'Chigeeng,Ontario,Canada /Meteo/Villes/can/Pages/CAON0790.htm
		{Ma-Me-O Beach,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0201.htm
		Maberly,Ontario,Canada /Meteo/Villes/can/Pages/CAON0391.htm
		Mabou,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0083.htm
		MacGregor,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0118.htm
		MacTier,Ontario,Canada /Meteo/Villes/can/Pages/CAON0394.htm
		Macamic,Québec,Canada /Meteo/Villes/can/Pages/CAQC0324.htm
		Maccan,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0084.htm
		Macdiarmid,Ontario,Canada /Meteo/Villes/can/Pages/CAON0392.htm
		{Maces Bay,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0060.htm
		Mackenzie,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0179.htm
		Macklin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0182.htm
		Macrorie,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0183.htm
		Madoc,Ontario,Canada /Meteo/Villes/can/Pages/CAON0395.htm
		Madsen,Ontario,Canada /Meteo/Villes/can/Pages/CAON0396.htm
		Mafeking,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0119.htm
		{Magnetawan First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1484.htm
		Magnetawan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0397.htm
		Magog,Québec,Canada /Meteo/Villes/can/Pages/CAQC0325.htm
		Magrath,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0202.htm
		{Mahone Bay,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0085.htm
		Maidstone,Ontario,Canada /Meteo/Villes/can/Pages/CAON0398.htm
		Maidstone,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0184.htm
		{Main Brook,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0164.htm
		Maitland,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0086.htm
		Maitland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0399.htm
		{Makkovik,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0165.htm
		Malartic,Québec,Canada /Meteo/Villes/can/Pages/CAQC0326.htm
		{Malay Falls,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0012.htm
		Mallorytown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0400.htm
		Malton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0401.htm
		Manic-Cinq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0327.htm
		Manigotagan,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0120.htm
		Manitouwadge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0402.htm
		Manitou,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0121.htm
		Manitowaning,Ontario,Canada /Meteo/Villes/can/Pages/CAON0403.htm
		Maniwaki,Québec,Canada /Meteo/Villes/can/Pages/CAQC0329.htm
		Mankota,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0185.htm
		Manning,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0203.htm
		Mannville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0204.htm
		Manor,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0186.htm
		Manotick,Ontario,Canada /Meteo/Villes/can/Pages/CAON0405.htm
		Manouane,Québec,Canada /Meteo/Villes/can/Pages/CAQC0330.htm
		Manseau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0331.htm
		Mansonville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0332.htm
		Manyberries,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0205.htm
		{Maple Creek,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0187.htm
		{Maple Grove,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0333.htm
		{Maple Ridge,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0181.htm
		Maple,Ontario,Canada /Meteo/Villes/can/Pages/CAON0406.htm
		Marathon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0407.htm
		Marcelin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0188.htm
		{Margaree Forks,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0087.htm
		Margo,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0189.htm
		Maria,Québec,Canada /Meteo/Villes/can/Pages/CAQC0334.htm
		Marieville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0335.htm
		{Marion Bridge,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0088.htm
		Markdale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0408.htm
		Markham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0409.htm
		Markstay,Ontario,Canada /Meteo/Villes/can/Pages/CAON0410.htm
		Marlboro,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0206.htm
		Marmora,Ontario,Canada /Meteo/Villes/can/Pages/CAON0411.htm
		Marquis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0190.htm
		Marsden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0191.htm
		{Marsh Lake,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0010.htm
		Marshall,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0192.htm
		Marsoui,Québec,Canada /Meteo/Villes/can/Pages/CAQC0336.htm
		{Marten Falls First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1509.htm
		{Marten River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0412.htm
		Martensville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0193.htm
		Martintown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0413.htm
		Marwayne,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0207.htm
		{Mary's Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0166.htm
		Maryfield,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0194.htm
		{Marystown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0167.htm
		Mascouche,Québec,Canada /Meteo/Villes/can/Pages/CAQC0337.htm
		Maskinongé,Québec,Canada /Meteo/Villes/can/Pages/CAQC0338.htm
		Masset,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0182.htm
		{Massey Drive,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0168.htm
		Massey,Ontario,Canada /Meteo/Villes/can/Pages/CAON0414.htm
		{Masson-Angers (Gatineau),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0339.htm
		Massueville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0340.htm
		Matachewan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0415.htm
		Matagami,Québec,Canada /Meteo/Villes/can/Pages/CAQC0341.htm
		Matane,Québec,Canada /Meteo/Villes/can/Pages/CAQC0342.htm
		Matapédia,Québec,Canada /Meteo/Villes/can/Pages/CAQC0343.htm
		Matheson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0416.htm
		Mattawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0417.htm
		Mattice,Ontario,Canada /Meteo/Villes/can/Pages/CAON0418.htm
		Maxville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0419.htm
		Mayerthorpe,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0208.htm
		Maymont,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0195.htm
		Maynooth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0420.htm
		Mayo,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0011.htm
		McAdam,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0061.htm
		McAuley,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0123.htm
		McCreary,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0124.htm
		{McDonalds Corners,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0421.htm
		McGregor,Ontario,Canada /Meteo/Villes/can/Pages/CAON0422.htm
		{McIver's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0170.htm
		McKellar,Ontario,Canada /Meteo/Villes/can/Pages/CAON0423.htm
		{McLeese Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0185.htm
		McLennan,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0209.htm
		{McLeod Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0186.htm
		McMasterville,Québec,Canada /Meteo/Villes/can/Pages/CAQC1209.htm
		Mcbride,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0184.htm
		Meacham,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0196.htm
		{Meadow Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0197.htm
		Meaford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0425.htm
		{Meander River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0210.htm
		{Meath Park,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0198.htm
		{Medicine Hat,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0211.htm
		Meductic,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0062.htm
		Melbourne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0426.htm
		Melbourne,Québec,Canada /Meteo/Villes/can/Pages/CAQC0344.htm
		Melfort,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0199.htm
		Melita,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0126.htm
		Mellin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0803.htm
		Melocheville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0345.htm
		Melrose,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0089.htm
		Melville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0200.htm
		Memramcook,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0063.htm
		Meota,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0201.htm
		Mercier,Québec,Canada /Meteo/Villes/can/Pages/CAQC0346.htm
		Merigomish,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0090.htm
		Merlin,Ontario,Canada /Meteo/Villes/can/Pages/CAON0427.htm
		Merrickville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0428.htm
		Merritt,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0187.htm
		Métabetchouan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0347.htm
		Metcalfe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0429.htm
		Meteghan,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0091.htm
		Métis-sur-Mer,Québec,Canada /Meteo/Villes/can/Pages/CAQC0348.htm
		Miami,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0127.htm
		{Mica Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0188.htm
		Midale,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0202.htm
		{Middle Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0203.htm
		Middleton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0092.htm
		Midland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0430.htm
		Midway,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0189.htm
		Milden,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0204.htm
		Mildmay,Ontario,Canada /Meteo/Villes/can/Pages/CAON0431.htm
		Milestone,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0205.htm
		{Milford Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0432.htm
		{Milk River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0212.htm
		Millbrook,Ontario,Canada /Meteo/Villes/can/Pages/CAON0433.htm
		{Millertown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0171.htm
		Millet,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0213.htm
		Millhaven,Ontario,Canada /Meteo/Villes/can/Pages/CAON1738.htm
		{Milltown-Head of Bay D'Espoir,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0172.htm
		Millville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0064.htm
		Milo,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0214.htm
		Milton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0434.htm
		Milverton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0435.htm
		Minaki,Ontario,Canada /Meteo/Villes/can/Pages/CAON0436.htm
		Minburn,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0215.htm
		Mindemoya,Ontario,Canada /Meteo/Villes/can/Pages/CAON0437.htm
		Minden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0438.htm
		{Mine Centre,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0439.htm
		{Ming's Bight,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0173.htm
		Miniota,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0128.htm
		Minnedosa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0130.htm
		Minton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0206.htm
		Minto,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0131.htm
		Minto,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0065.htm
		Mirabel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0350.htm
		Miramichi,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0066.htm
		Mirror,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0216.htm
		{Miscou Island,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0192.htm
		Missanabie,Ontario,Canada /Meteo/Villes/can/Pages/CAON0440.htm
		Mission,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0190.htm
		Mississauga,Ontario,Canada /Meteo/Villes/can/Pages/CAON0441.htm
		Mistassini,Québec,Canada /Meteo/Villes/can/Pages/CAQC0351.htm
		Mistatim,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0207.htm
		Mitchell,Ontario,Canada /Meteo/Villes/can/Pages/CAON0442.htm
		{Mohawks Of The Bay of Quinte First Nations,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1503.htm
		Moisie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0352.htm
		Molanosa,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0208.htm
		Monastery,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0094.htm
		Moncton,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0067.htm
		{Monkstown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0174.htm
		Monkton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0443.htm
		{Mont Bechervaise,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1285.htm
		{Mont St Grégoire,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1210.htm
		Mont-Joli,Québec,Canada /Meteo/Villes/can/Pages/CAQC0353.htm
		Mont-Laurier,Québec,Canada /Meteo/Villes/can/Pages/CAQC0354.htm
		Mont-Louis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0355.htm
		Mont-Rolland,Québec,Canada /Meteo/Villes/can/Pages/CAQC0356.htm
		{Mont-Royal (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0357.htm
		Mont-Saint-Hilaire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0358.htm
		Mont-Saint-Pierre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0359.htm
		Mont-Tremblant,Québec,Canada /Meteo/Villes/can/Pages/CAQC0360.htm
		Montague,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0013.htm
		Montebello,Québec,Canada /Meteo/Villes/can/Pages/CAQC0361.htm
		Montmagny,Québec,Canada /Meteo/Villes/can/Pages/CAQC0362.htm
		Montmartre,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0209.htm
		Montney,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0191.htm
		{Montréal - Est,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1212.htm
		{Montréal - Nord,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1213.htm
		{Montréal - Ouest,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1214.htm
		Montréal,Québec,Canada /Meteo/Villes/can/Pages/CAQC0363.htm
		Moonbeam,Ontario,Canada /Meteo/Villes/can/Pages/CAON0444.htm
		Moonstone,Ontario,Canada /Meteo/Villes/can/Pages/CAON0445.htm
		Mooretown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0446.htm
		{Moose Creek,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0447.htm
		{Moose Factory,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0448.htm
		{Moose Jaw,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0210.htm
		{Moose Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0132.htm
		Moosomin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0211.htm
		Moosonee,Ontario,Canada /Meteo/Villes/can/Pages/CAON0449.htm
		Morden,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0133.htm
		Morell,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0014.htm
		Morin-Heights,Québec,Canada /Meteo/Villes/can/Pages/CAQC0364.htm
		Morinville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0217.htm
		Morley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0218.htm
		Morrin,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0219.htm
		Morrisburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0450.htm
		Morris,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0134.htm
		Morse,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0212.htm
		Morson,Ontario,Canada /Meteo/Villes/can/Pages/CAON0451.htm
		Mortlach,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0213.htm
		Mossbank,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0214.htm
		{Mount Albert,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0452.htm
		{Mount Brydges,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0453.htm
		{Mount Carmel-Mitchells Brook-St. Catherines,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0177.htm
		{Mount Forest,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0454.htm
		{Mount Hope,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0455.htm
		{Mount Moriah,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0178.htm
		{Mount Pearl,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0179.htm
		{Mount Pleasant,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0456.htm
		{Mount Stewart,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0015.htm
		{Mount Uniacke,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0095.htm
		Moyie,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0192.htm
		Mulgrave,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0096.htm
		Mulhurst,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0220.htm
		{Muncho Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0193.htm
		Mundare,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0221.htm
		Murdochville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0365.htm
		{Murray River,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0016.htm
		{Musgrave Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0180.htm
		{Musgravetown,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0181.htm
		{Muskoka Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1764.htm
		Muskoka,Ontario,Canada /Meteo/Villes/can/Pages/CAON0774.htm
		{Muskrat Dam First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1584.htm
		{Muskrat Dam,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0458.htm
		{Musquodoboit Harbour,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0097.htm
		{Mutton Bay,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0366.htm
		Myrnam,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0222.htm
		Nackawic,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0068.htm
		{Nahanni Butte,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0019.htm
		Naicam,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0215.htm
		{Nain,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0182.htm
		Nairn,Ontario,Canada /Meteo/Villes/can/Pages/CAON0459.htm
		{Naiscoutaing First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1479.htm
		Nakina,Ontario,Canada /Meteo/Villes/can/Pages/CAON0460.htm
		Nakusp,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0194.htm
		Namao,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0223.htm
		Nampa,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0224.htm
		Nanaimo,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0195.htm
		Nantes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0367.htm
		Nanticoke,Ontario,Canada /Meteo/Villes/can/Pages/CAON0461.htm
		Nanton,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0225.htm
		Napanee,Ontario,Canada /Meteo/Villes/can/Pages/CAON0462.htm
		Napierville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0368.htm
		Naramata,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0197.htm
		Natashquan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0369.htm
		{Natuashish,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0069.htm
		Navan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0463.htm
		Nedelec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0370.htm
		Neepawa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0135.htm
		Neguac,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0069.htm
		Neidpath,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0216.htm
		Neilburg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0217.htm
		{Nelson House,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0136.htm
		Nelson,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0198.htm
		Nepean,Ontario,Canada /Meteo/Villes/can/Pages/CAON0464.htm
		Nephton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0465.htm
		{Nestor Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0466.htm
		Neudorf,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0218.htm
		Neustadt,Ontario,Canada /Meteo/Villes/can/Pages/CAON0467.htm
		Neuville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0372.htm
		Neville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0219.htm
		{New Aiyansh,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0009.htm
		{New Carlisle,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0373.htm
		{New Dayton,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0226.htm
		{New Denmark,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0070.htm
		{New Denver,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0199.htm
		{New Dundee,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0468.htm
		{New Germany,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0099.htm
		{New Glasgow,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0100.htm
		{New Glasgow,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0374.htm
		{New Hamburg,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0469.htm
		{New Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0184.htm
		{New Haven,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0017.htm
		{New Liskeard,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0470.htm
		{New London,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0018.htm
		{New Norway,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0227.htm
		{New Perlican,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0185.htm
		{New Richmond,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0375.htm
		{New Ross,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0101.htm
		{New Sarepta,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0228.htm
		{New Tecumseth,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0471.htm
		{New Waterford,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0102.htm
		{New Westminster,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0200.htm
		{New-Wes-Valley,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0186.htm
		Newbrook,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0229.htm
		Newburgh,Ontario,Canada /Meteo/Villes/can/Pages/CAON0472.htm
		Newcastle,Ontario,Canada /Meteo/Villes/can/Pages/CAON1762.htm
		Newdale,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0137.htm
		Newmarket,Ontario,Canada /Meteo/Villes/can/Pages/CAON0473.htm
		{Newport (Chandler),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0376.htm
		Newtonville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0474.htm
		{Niagara Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0475.htm
		Niagara-on-the-Lake,Ontario,Canada /Meteo/Villes/can/Pages/CAON0476.htm
		{Nickel Centre,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0477.htm
		Nicolet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0377.htm
		{Nimpo Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0202.htm
		Nipawin,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0220.htm
		Nipigon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0478.htm
		{Nipissing First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1555.htm
		{Nippers Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0188.htm
		Nisku,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0230.htm
		{Niton Junction,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0231.htm
		Niverville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0139.htm
		Nobel,Ontario,Canada /Meteo/Villes/can/Pages/CAON0479.htm
		Nobleford,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0232.htm
		Nobleton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0480.htm
		Noelville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0481.htm
		Noel,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0103.htm
		Nokomis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0221.htm
		Norbertville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0379.htm
		Nordegg,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0233.htm
		{Norman Wells,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0020.htm
		{Norman's Cove-Long Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0190.htm
		Normandin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0380.htm
		Normétal,Québec,Canada /Meteo/Villes/can/Pages/CAQC0381.htm
		Norquay,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0222.htm
		{Norris Arm,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0191.htm
		{North Augusta,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0483.htm
		{North Battleford,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0223.htm
		{North Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0484.htm
		{North Gower,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0485.htm
		{North Hatley,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0382.htm
		{North Mountain,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0020.htm
		{North Portal,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0224.htm
		{North Saanich,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0341.htm
		{North Spirit Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0486.htm
		{North Sydney,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0104.htm
		{North Vancouver,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0205.htm
		{North West River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0192.htm
		{North York,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0487.htm
		Northbrook,Ontario,Canada /Meteo/Villes/can/Pages/CAON0488.htm
		{Northern Arm,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0193.htm
		Norton,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0072.htm
		Norval,Ontario,Canada /Meteo/Villes/can/Pages/CAON1739.htm
		{Norway House,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0140.htm
		Norwich,Ontario,Canada /Meteo/Villes/can/Pages/CAON0489.htm
		Norwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0491.htm
		{Notre Dame De L'Ile Perrot,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1215.htm
		{Notre Dame Des Prairies,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1216.htm
		{Notre Dame Du Portage,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1217.htm
		{Notre Dame de Bonsecours,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1211.htm
		{Notre Dame de Lourdes,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0142.htm
		Notre-Dame-de-Lourdes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0383.htm
		Notre-Dame-de-Stanbridge,Québec,Canada /Meteo/Villes/can/Pages/CAQC0387.htm
		Notre-Dame-de-la-Paix,Québec,Canada /Meteo/Villes/can/Pages/CAQC0385.htm
		Notre-Dame-de-la-Salette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0386.htm
		Notre-Dame-des-Laurentides,Québec,Canada /Meteo/Villes/can/Pages/CAQC0384.htm
		Notre-Dame-du-Bon-Conseil,Québec,Canada /Meteo/Villes/can/Pages/CAQC0388.htm
		Notre-Dame-du-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0389.htm
		Notre-Dame-du-Laus,Québec,Canada /Meteo/Villes/can/Pages/CAQC0390.htm
		Notre-Dame-du-Nord,Québec,Canada /Meteo/Villes/can/Pages/CAQC0391.htm
		Nouvelle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0392.htm
		O'Leary,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0019.htm
		{Oak Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0143.htm
		{Oak Ridges,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0492.htm
		{Oak River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0144.htm
		Oakville,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0147.htm
		Oakville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0493.htm
		Oakwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0494.htm
		Oba,Ontario,Canada /Meteo/Villes/can/Pages/CAON0495.htm
		{Ocean Falls,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0206.htm
		{Ocean Park,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0750.htm
		{Ochre River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0148.htm
		Odessa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0496.htm
		Odessa,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0225.htm
		Ogema,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0226.htm
		Ogoki,Ontario,Canada /Meteo/Villes/can/Pages/CAON0497.htm
		Ohsweken,Ontario,Canada /Meteo/Villes/can/Pages/CAON0498.htm
		{Oil Springs,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0499.htm
		{Ojibways of Hiawatha First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1511.htm
		{Ojibways of Walpole Island First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1526.htm
		{Okanagan Falls,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0207.htm
		Oka,Québec,Canada /Meteo/Villes/can/Pages/CAQC0394.htm
		Okotoks,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0234.htm
		{Old Crow,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0012.htm
		{Old Perlican,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0194.htm
		Olds,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0235.htm
		Oliver,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0209.htm
		Omemee,Ontario,Canada /Meteo/Villes/can/Pages/CAON0500.htm
		Omerville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0395.htm
		{Onaping Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0501.htm
		{Oneida First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1553.htm
		Onoway,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0236.htm
		Opasatika,Ontario,Canada /Meteo/Villes/can/Pages/CAON0502.htm
		Ophir,Ontario,Canada /Meteo/Villes/can/Pages/CAON0503.htm
		Orangeville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0505.htm
		Orford,Québec,Canada /Meteo/Villes/can/Pages/CAQC1237.htm
		Orillia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0506.htm
		Orléans,Ontario,Canada /Meteo/Villes/can/Pages/CAON0507.htm
		Ormiston,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0227.htm
		Ormstown,Québec,Canada /Meteo/Villes/can/Pages/CAQC0396.htm
		Oromocto,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0073.htm
		Orono,Ontario,Canada /Meteo/Villes/can/Pages/CAON0509.htm
		Oro,Ontario,Canada /Meteo/Villes/can/Pages/CAON0508.htm
		Orrville,Ontario,Canada /Meteo/Villes/can/Pages/CAON1740.htm
		Osgoode,Ontario,Canada /Meteo/Villes/can/Pages/CAON0510.htm
		Oshawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0511.htm
		Osler,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0228.htm
		Osoyoos,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0210.htm
		Ottawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0512.htm
		{Otterburn Park,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0397.htm
		Otterville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0514.htm
		Outlook,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0229.htm
		{Outremont (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0398.htm
		{Owen Sound,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0515.htm
		Oxbow,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0230.htm
		Oxdrift,Ontario,Canada /Meteo/Villes/can/Pages/CAON0516.htm
		{Oxford House,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0149.htm
		{Oxford Mills,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1741.htm
		Oxford,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0105.htm
		Oyama,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0211.htm
		Oyen,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0237.htm
		{Pabos (Chandler),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0092.htm
		{Packs Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0195.htm
		{Pacquet,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0196.htm
		Paddockwood,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0231.htm
		Paisley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0517.htm
		Pakenham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0518.htm
		Palgrave,Ontario,Canada /Meteo/Villes/can/Pages/CAON0519.htm
		Palmarolle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0399.htm
		{Palmer Rapids,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0520.htm
		Palmerston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0521.htm
		Pangman,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0232.htm
		Panorama,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0403.htm
		Papineauville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0400.htm
		{Paquette Corner,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1742.htm
		Paquetville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0074.htm
		{Paradise Hill,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0233.htm
		{Paradise River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0198.htm
		{Paradise Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0238.htm
		{Paradise,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0197.htm
		Parent,Québec,Canada /Meteo/Villes/can/Pages/CAQC0403.htm
		Parham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0522.htm
		Paris,Ontario,Canada /Meteo/Villes/can/Pages/CAON0523.htm
		Parkhill,Ontario,Canada /Meteo/Villes/can/Pages/CAON0524.htm
		Parksville,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0213.htm
		Parrsboro,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0106.htm
		{Parry Sound,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0525.htm
		Parson,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0214.htm
		{Pasadena,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0199.htm
		{Pass Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0526.htm
		Patuanak,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0234.htm
		Paynton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0235.htm
		{Peace River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0239.htm
		Peachland,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0215.htm
		Peawanuck,Ontario,Canada /Meteo/Villes/can/Pages/CAON0527.htm
		{Peerless Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0240.htm
		Peers,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0241.htm
		Pefferlaw,Ontario,Canada /Meteo/Villes/can/Pages/CAON0424.htm
		{Peggy's Cove,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0107.htm
		Peguis,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0390.htm
		{Pelee Island,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0529.htm
		Pelham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0530.htm
		{Pelican Narrows,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0236.htm
		{Pelican Rapids,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0150.htm
		{Pelly Crossing,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0013.htm
		Pelly,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0237.htm
		Pemberton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0216.htm
		Pembroke,Ontario,Canada /Meteo/Villes/can/Pages/CAON0531.htm
		Penetanguishene,Ontario,Canada /Meteo/Villes/can/Pages/CAON0532.htm
		Penhold,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0242.htm
		Pennant,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0238.htm
		Pense,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0239.htm
		Penticton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0218.htm
		Percé,Québec,Canada /Meteo/Villes/can/Pages/CAQC0405.htm
		Perdue,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0240.htm
		Péribonka,Québec,Canada /Meteo/Villes/can/Pages/CAQC0406.htm
		Perkins,Québec,Canada /Meteo/Villes/can/Pages/CAQC0407.htm
		{Perrault Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0533.htm
		Perth-Andover,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0075.htm
		Perth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0534.htm
		Petawawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0535.htm
		Peterborough,Ontario,Canada /Meteo/Villes/can/Pages/CAON0536.htm
		{Peterview,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0200.htm
		{Petit Rocher,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0076.htm
		Petitcodiac,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0077.htm
		Petite-Rivière-Saint-Francois,Québec,Canada /Meteo/Villes/can/Pages/CAQC0408.htm
		Petrolia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0537.htm
		{Petty Harbour-Maddox Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0202.htm
		Philipsburg,Québec,Canada /Meteo/Villes/can/Pages/CAQC0409.htm
		Piapot,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0241.htm
		Pickering,Ontario,Canada /Meteo/Villes/can/Pages/CAON0538.htm
		{Pickle Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0539.htm
		Picton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0540.htm
		Pictou,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0108.htm
		{Picture Butte,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0243.htm
		Pierceland,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0242.htm
		{Pierrefonds (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0410.htm
		Pierreville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0411.htm
		{Pikangikum First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1534.htm
		Pikwitonei,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0153.htm
		{Pilot Butte,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0243.htm
		{Pilot Mound,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0154.htm
		Pinawa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0155.htm
		{Pincher Creek,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0244.htm
		Pincourt,Québec,Canada /Meteo/Villes/can/Pages/CAQC0412.htm
		{Pine Dock,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0156.htm
		{Pine Falls,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0157.htm
		{Pine River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0158.htm
		{Pineal Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0542.htm
		Pinehouse,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0244.htm
		Piney,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0159.htm
		Pintendre,Québec,Canada /Meteo/Villes/can/Pages/CAQC1218.htm
		{Pitt Meadows,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0220.htm
		{Placentia,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0204.htm
		Plaisance,Québec,Canada /Meteo/Villes/can/Pages/CAQC1219.htm
		Plamondon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0245.htm
		Plantagenet,Ontario,Canada /Meteo/Villes/can/Pages/CAON0543.htm
		{Plaster Rock,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0078.htm
		{Plate Cove East,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0205.htm
		Plato,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0245.htm
		Plattsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0544.htm
		{Pleasant Park,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0545.htm
		Plenty,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0246.htm
		Plessisville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0413.htm
		Plevna,Ontario,Canada /Meteo/Villes/can/Pages/CAON0546.htm
		{Plum Coulee,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0161.htm
		Plumas,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0162.htm
		Pohénégamook,Québec,Canada /Meteo/Villes/can/Pages/CAQC0414.htm
		{Point Grondine First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1478.htm
		{Point Leamington,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0206.htm
		{Point Pelee,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0547.htm
		{Pointe Aux Trembles,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1220.htm
		{Pointe au Baril,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0548.htm
		{Pointe du Bois,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0163.htm
		Pointe-Calumet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0418.htm
		{Pointe-Claire (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0419.htm
		Pointe-Fortune,Québec,Canada /Meteo/Villes/can/Pages/CAQC0422.htm
		Pointe-Lebel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0423.htm
		Pointe-Verte,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0248.htm
		Pointe-à-la-Croix,Québec,Canada /Meteo/Villes/can/Pages/CAQC0415.htm
		{Pointe-au-Père (Rimouski),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0416.htm
		Pointe-aux-Outardes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0417.htm
		Pointe-des-Cascades,Québec,Canada /Meteo/Villes/can/Pages/CAQC0420.htm
		Pointe-des-Monts,Québec,Canada /Meteo/Villes/can/Pages/CAQC0421.htm
		Ponoka,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0246.htm
		Pont-Rouge,Québec,Canada /Meteo/Villes/can/Pages/CAQC0426.htm
		Pont-Viau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0425.htm
		Ponteix,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0247.htm
		Pontiac,Québec,Canada /Meteo/Villes/can/Pages/CAQC1221.htm
		{Pool's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0207.htm
		{Poplar River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0165.htm
		Poplarfield,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0166.htm
		{Porcupine Plain,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0248.htm
		{Port Alberni,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0221.htm
		{Port Alice,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0222.htm
		{Port Aux Basques,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0211.htm
		{Port Bickerton,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0109.htm
		{Port Blandford,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0212.htm
		{Port Burwell,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0550.htm
		{Port Carling,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0551.htm
		{Port Clements,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0223.htm
		{Port Colborne,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0552.htm
		{Port Coquitlam,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0224.htm
		{Port Credit,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0553.htm
		{Port Cunnington,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1718.htm
		{Port Dover,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0554.htm
		{Port Dufferin,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0110.htm
		{Port Edward,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0225.htm
		{Port Elgin,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0079.htm
		{Port Elgin,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0555.htm
		{Port Franks,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0556.htm
		{Port Greville,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0111.htm
		{Port Hardy,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0226.htm
		{Port Hawkesbury,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0112.htm
		{Port Hood,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0113.htm
		{Port Hope Simpson,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0213.htm
		{Port Hope,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0557.htm
		{Port La Tour,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0114.htm
		{Port Lambton,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0558.htm
		{Port Loring,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0559.htm
		{Port Maitland,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0116.htm
		{Port McNeill,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0227.htm
		{Port McNicoll,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0561.htm
		{Port Mellon,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0228.htm
		{Port Moody,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0229.htm
		{Port Morien,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0117.htm
		{Port Mouton,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0118.htm
		{Port Perry,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0562.htm
		{Port Renfrew,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0230.htm
		{Port Rexton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0214.htm
		{Port Robinson,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0563.htm
		{Port Rowan,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0564.htm
		{Port Saunders,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0215.htm
		{Port Severn,Ontario,Canada} /Meteo/Villes/can/Pages/CAON2027.htm
		{Port Stanley,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0565.htm
		{Port Sydney,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0566.htm
		{Port Union,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0216.htm
		{Port au Choix,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0209.htm
		{Port au Port West-Aguathuna-Felix Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0210.htm
		Port-Cartier,Québec,Canada /Meteo/Villes/can/Pages/CAQC0430.htm
		Port-Daniel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0431.htm
		{Port-Menier (l'Île d'Anticosti),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0429.htm
		{Portage La Prairie,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0167.htm
		Portage-du-Fort,Québec,Canada /Meteo/Villes/can/Pages/CAQC0432.htm
		Portland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0567.htm
		Portneuf,Québec,Canada /Meteo/Villes/can/Pages/CAQC0433.htm
		{Portugal Cove-St. Philip's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0217.htm
		Poste-de-la-Baleine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0435.htm
		{Postville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0218.htm
		{Pouce Coupe,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0232.htm
		{Pouch Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0219.htm
		Powassan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0568.htm
		{Powell River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0233.htm
		Preeceville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0249.htm
		Prelate,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0250.htm
		Prescott,Ontario,Canada /Meteo/Villes/can/Pages/CAON0569.htm
		Prespatou,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0234.htm
		Preston,Ontario,Canada /Meteo/Villes/can/Pages/CAON0570.htm
		Prevost,Québec,Canada /Meteo/Villes/can/Pages/CAQC1222.htm
		Price,Québec,Canada /Meteo/Villes/can/Pages/CAQC0437.htm
		{Prince Albert,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0251.htm
		{Prince George,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0235.htm
		{Prince Rupert,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0236.htm
		Princeton,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0237.htm
		Princeton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0571.htm
		{Princeton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0220.htm
		Princeville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0438.htm
		{Prophet River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0239.htm
		Provost,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0248.htm
		Prud'homme,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0252.htm
		Pubnico,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0120.htm
		Puce,Ontario,Canada /Meteo/Villes/can/Pages/CAON1743.htm
		Pugwash,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0121.htm
		Punnichy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0253.htm
		Puvirnituq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0439.htm
		Qu'Appelle,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0254.htm
		{Quadra Island,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0241.htm
		{Qualicum Beach,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0242.htm
		Québec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0441.htm
		{Queen Charlotte,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0243.htm
		Queensport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0122.htm
		Queenston,Ontario,Canada /Meteo/Villes/can/Pages/CAON1744.htm
		Queensville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0572.htm
		Quesnel,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0244.htm
		{Quill Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0255.htm
		{Quinte West,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1974.htm
		Quispamsis,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0080.htm
		Quyon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0442.htm
		{Rabbit Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0256.htm
		Radisson,Québec,Canada /Meteo/Villes/can/Pages/CAQC0443.htm
		Radisson,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0257.htm
		{Radium Hot Springs,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0245.htm
		Radville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0258.htm
		Radway,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0249.htm
		{Rae Lakes,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0023.htm
		{Rae,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0022.htm
		{Rainbow Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0250.htm
		{Rainy Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1576.htm
		{Rainy River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0573.htm
		Raith,Ontario,Canada /Meteo/Villes/can/Pages/CAON0574.htm
		{Raleigh,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0221.htm
		Ralston,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0251.htm
		{Ramea,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0222.htm
		Ramore,Ontario,Canada /Meteo/Villes/can/Pages/CAON0575.htm
		{Rankin Inlet,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0021.htm
		{Rapid City,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0169.htm
		Rathwell,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0170.htm
		Rawdon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0444.htm
		Raymond,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0252.htm
		Raymore,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0259.htm
		Rayside-Balfour,Ontario,Canada /Meteo/Villes/can/Pages/CAON0577.htm
		{Red Bank,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0081.htm
		{Red Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0223.htm
		{Red Deer,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0253.htm
		{Red Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0578.htm
		{Red Rock,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0246.htm
		{Red Rock,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0579.htm
		{Red Sucker Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0171.htm
		Redbridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0580.htm
		Redcliff,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0255.htm
		Redditt,Ontario,Canada /Meteo/Villes/can/Pages/CAON0581.htm
		Redvers,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0260.htm
		Redwater,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0256.htm
		{Reefs Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0224.htm
		{Regina Beach,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0262.htm
		Regina,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0261.htm
		Remigny,Québec,Canada /Meteo/Villes/can/Pages/CAQC0445.htm
		{Rencontre East,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0225.htm
		Renfrew,Ontario,Canada /Meteo/Villes/can/Pages/CAON0582.htm
		Rennie,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0172.htm
		Repentigny,Québec,Canada /Meteo/Villes/can/Pages/CAQC0446.htm
		{Réserve faunique Ashuapmushuan,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0807.htm
		{Réserve faunique La Vérendrye,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0401.htm
		{Réserve faunique Mastigouche,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0809.htm
		{Réserve faunique de Rimouski,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0811.htm
		{Réserves fauniques de Matane et de Dunière,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0810.htm
		Resolute,Nunavut,Canada /Meteo/Villes/can/Pages/CANU0023.htm
		Reston,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0173.htm
		Restoule,Ontario,Canada /Meteo/Villes/can/Pages/CAON0583.htm
		Revelstoke,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0247.htm
		Rhein,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0263.htm
		Riceton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0264.htm
		Richelieu,Québec,Canada /Meteo/Villes/can/Pages/CAQC0447.htm
		Richibucto,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0082.htm
		{Richmond Hill,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0585.htm
		Richmond,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0248.htm
		Richmond,Ontario,Canada /Meteo/Villes/can/Pages/CAON0584.htm
		Richmond,Québec,Canada /Meteo/Villes/can/Pages/CAQC0448.htm
		Richmound,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0265.htm
		Ridgedale,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0266.htm
		Ridgetown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0586.htm
		Ridgeway,Ontario,Canada /Meteo/Villes/can/Pages/CAON0587.htm
		Rigaud,Québec,Canada /Meteo/Villes/can/Pages/CAQC0449.htm
		{Rigolet,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0226.htm
		Rimbey,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0257.htm
		Rimouski-Est,Québec,Canada /Meteo/Villes/can/Pages/CAQC0451.htm
		Rimouski,Québec,Canada /Meteo/Villes/can/Pages/CAQC0450.htm
		Riondel,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0249.htm
		Ripley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0588.htm
		Ripon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0452.htm
		{Riske Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0250.htm
		{River Hebert,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0123.htm
		{River John,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0124.htm
		{River of Ponds,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0227.htm
		Riverhurst,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0267.htm
		Riverport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0125.htm
		Rivers,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0174.htm
		Riverton,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0175.htm
		Riverview,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0083.htm
		Rivière-Beaudette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0456.htm
		Rivière-Bleue,Québec,Canada /Meteo/Villes/can/Pages/CAQC0457.htm
		Rivière-Héva,Québec,Canada /Meteo/Villes/can/Pages/CAQC0459.htm
		Rivière-Saint-Jean,Québec,Canada /Meteo/Villes/can/Pages/CAQC0460.htm
		Rivière-à-Pierre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0453.htm
		Rivière-au-Renard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0454.htm
		Rivière-au-Tonnerre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0455.htm
		Rivière-du-Loup,Québec,Canada /Meteo/Villes/can/Pages/CAQC0458.htm
		Robb,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0258.htm
		{Robert's Arm,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0228.htm
		Robertsonville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0461.htm
		Roberval,Québec,Canada /Meteo/Villes/can/Pages/CAQC0462.htm
		Roblin,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0176.htm
		Rocanville,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0268.htm
		Rochebaucourt,Québec,Canada /Meteo/Villes/can/Pages/CAQC0463.htm
		Rochester,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0259.htm
		{Rock Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0251.htm
		{Rock Forest (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0464.htm
		Rockglen,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0269.htm
		Rockland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0589.htm
		Rockwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0590.htm
		{Rocky Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0229.htm
		{Rocky Mountain House,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0260.htm
		Rockyford,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0261.htm
		{Roddickton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0230.htm
		Rodney,Ontario,Canada /Meteo/Villes/can/Pages/CAON0591.htm
		Rogersville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0084.htm
		Roland,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0177.htm
		Rolla,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0252.htm
		Rollet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0466.htm
		{Rolling Hills,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0262.htm
		Rolphton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0592.htm
		Rondeau,Ontario,Canada /Meteo/Villes/can/Pages/CAON0593.htm
		Rorketon,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0178.htm
		Rosalind,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0263.htm
		{Rose Blanche-Harbour Le Cou,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0231.htm
		{Rose Valley,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0270.htm
		Rosebud,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0264.htm
		Rosemère,Québec,Canada /Meteo/Villes/can/Pages/CAQC0467.htm
		Roseneath,Ontario,Canada /Meteo/Villes/can/Pages/CAON0594.htm
		Rosetown,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0271.htm
		{Ross River,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0014.htm
		Rossburn,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0179.htm
		Rosseau,Ontario,Canada /Meteo/Villes/can/Pages/CAON0595.htm
		Rossland,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0254.htm
		Rosthern,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0272.htm
		Rothesay,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0085.htm
		Rougemont,Québec,Canada /Meteo/Villes/can/Pages/CAQC0468.htm
		Rouleau,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0273.htm
		Rouyn-Noranda,Québec,Canada /Meteo/Villes/can/Pages/CAQC0469.htm
		{Roxboro (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0470.htm
		{Roxton Falls,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0471.htm
		{Roxton Pond,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0472.htm
		Rumsey,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0265.htm
		{Rushoon,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0232.htm
		Russell,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0180.htm
		Russell,Ontario,Canada /Meteo/Villes/can/Pages/CAON0597.htm
		Rusticoville,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0020.htm
		Ruthven,Ontario,Canada /Meteo/Villes/can/Pages/CAON1745.htm
		Rycroft,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0266.htm
		Ryley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0267.htm
		Saanich,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0256.htm
		Sabrevois,Québec,Canada /Meteo/Villes/can/Pages/CAQC1223.htm
		{Sachigo First Nation Reserve 3,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1582.htm
		Sackville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0086.htm
		Sacré-Coeur,Québec,Canada /Meteo/Villes/can/Pages/CAQC0473.htm
		Saguenay,Québec,Canada /Meteo/Villes/can/Pages/CAQC0996.htm
		{Saint Alexandre D'Iberville,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1224.htm
		{Saint Alphonse de Granby,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1225.htm
		{Saint Amable,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1226.htm
		{Saint Andrews,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0087.htm
		{Saint Antoine Des Laurentides,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1276.htm
		{Saint Antoine Sur Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1227.htm
		{Saint Antonin,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1228.htm
		{Saint Athanase,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1229.htm
		{Saint Calixte,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1230.htm
		{Saint Charles Borromee,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1231.htm
		{Saint Charles Sur Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1232.htm
		{Saint Christophe D'Arthabaska,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1233.htm
		{Saint Clair Beach,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1749.htm
		{Saint Colomban,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1234.htm
		{Saint Denis De Brompton,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1235.htm
		{Saint Denis Sur Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1236.htm
		{Saint Esprit,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1238.htm
		{Saint Etienne de Beauharnois,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1239.htm
		{Saint Etienne de Lauzon,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1240.htm
		{Saint Gerard Majella,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1242.htm
		{Saint Isidore de la Prairie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1243.htm
		{Saint Jean Baptiste,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1244.htm
		{Saint Jean D'Orleans,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1245.htm
		{Saint Joachim,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1246.htm
		{Saint John,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0088.htm
		{Saint Joseph De La Pointe De Levy,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1277.htm
		{Saint Laurent D'Orleans,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1247.htm
		{Saint Lazare De Vaudreuil,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1248.htm
		{Saint Lin Laurentides,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1249.htm
		{Saint Marc Sur Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1250.htm
		{Saint Mathias Sur Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1251.htm
		{Saint Mathieu de Beloeil,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1252.htm
		{Saint Mathieu de la Prairie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1253.htm
		{Saint Maurice,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1254.htm
		{Saint Norbert D'Arthabaska,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1255.htm
		{Saint Paul D'Industrie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1256.htm
		{Saint Philippe,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1257.htm
		{Saint Pierre D'Orleans,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1258.htm
		{Saint Robert,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1259.htm
		{Saint Roch De L'Achigan,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1260.htm
		{Saint Roch De Richelieu,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1261.htm
		{Saint Sulpice,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1262.htm
		{Saint Thomas,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1263.htm
		{Saint Urbain Premier,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1264.htm
		{Saint Valere,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1265.htm
		Saint-Adelphe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0530.htm
		Saint-Adolphe-d'Howard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0531.htm
		Saint-Adolphe-de-Dudswell,Québec,Canada /Meteo/Villes/can/Pages/CAQC0532.htm
		Saint-Agapit,Québec,Canada /Meteo/Villes/can/Pages/CAQC0533.htm
		Saint-Aimé,Québec,Canada /Meteo/Villes/can/Pages/CAQC0534.htm
		{Saint-Alban's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0246.htm
		Saint-Albert,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0284.htm
		Saint-Albert,Québec,Canada /Meteo/Villes/can/Pages/CAQC0535.htm
		Saint-Alexandre-de-Kamouraska,Québec,Canada /Meteo/Villes/can/Pages/CAQC0536.htm
		Saint-Alexis-de-Matapédia,Québec,Canada /Meteo/Villes/can/Pages/CAQC0538.htm
		Saint-Alexis-de-Montcalm,Québec,Canada /Meteo/Villes/can/Pages/CAQC0537.htm
		Saint-Alexis-des-Monts,Québec,Canada /Meteo/Villes/can/Pages/CAQC0539.htm
		Saint-Alphonse-Rodriguez,Québec,Canada /Meteo/Villes/can/Pages/CAQC0540.htm
		Saint-Ambroise-de-Chicoutimi,Québec,Canada /Meteo/Villes/can/Pages/CAQC0495.htm
		Saint-André,Québec,Canada /Meteo/Villes/can/Pages/CAQC0541.htm
		Saint-André-Avellin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0542.htm
		Saint-André-Est,Québec,Canada /Meteo/Villes/can/Pages/CAQC0544.htm
		Saint-André-du-Lac-Saint-Jean,Québec,Canada /Meteo/Villes/can/Pages/CAQC0543.htm
		Saint-Anselme,Québec,Canada /Meteo/Villes/can/Pages/CAQC0545.htm
		{Saint-Anthony,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0247.htm
		{Saint-Antoine (Saint-Jérôme),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0546.htm
		Saint-Antoine,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0097.htm
		Saint-Antoine-de-Tilly,Québec,Canada /Meteo/Villes/can/Pages/CAQC0547.htm
		Saint-Apollinaire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0548.htm
		{Saint-Augustin-de-Desmaures (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0549.htm
		Saint-Barnabé,Québec,Canada /Meteo/Villes/can/Pages/CAQC0550.htm
		Saint-Barthélemy,Québec,Canada /Meteo/Villes/can/Pages/CAQC0551.htm
		Saint-Basile,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0098.htm
		Saint-Basile-Sud,Québec,Canada /Meteo/Villes/can/Pages/CAQC0553.htm
		Saint-Basile-de-Portneuf,Québec,Canada /Meteo/Villes/can/Pages/CAQC0497.htm
		Saint-Basile-le-Grand,Québec,Canada /Meteo/Villes/can/Pages/CAQC0552.htm
		Saint-Benedict,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0296.htm
		{Saint-Bernard's-Jacques Fontaine,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0248.htm
		Saint-Bernard-de-Dorchester,Québec,Canada /Meteo/Villes/can/Pages/CAQC0498.htm
		Saint-Blaise-sur-Richelieu,Québec,Canada /Meteo/Villes/can/Pages/CAQC0554.htm
		Saint-Boniface-de-Shawinigan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0555.htm
		{Saint-Brendan's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0249.htm
		{Saint-Bride's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0250.htm
		Saint-Brieux,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0297.htm
		Saint-Bruno,Québec,Canada /Meteo/Villes/can/Pages/CAQC0556.htm
		Saint-Bruno-de-Montarville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0557.htm
		Saint-Calixte-de-Kilkenny,Québec,Canada /Meteo/Villes/can/Pages/CAQC0558.htm
		Saint-Casimir,Québec,Canada /Meteo/Villes/can/Pages/CAQC0559.htm
		Saint-Catharines,Ontario,Canada /Meteo/Villes/can/Pages/CAON0638.htm
		Saint-Célestin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0560.htm
		Saint-Césaire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0561.htm
		Saint-Charles,Ontario,Canada /Meteo/Villes/can/Pages/CAON0639.htm
		Saint-Charles-de-Bellechasse,Québec,Canada /Meteo/Villes/can/Pages/CAQC0562.htm
		Saint-Chrysostome,Québec,Canada /Meteo/Villes/can/Pages/CAQC0563.htm
		Saint-Claude,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0201.htm
		Saint-Clements,Ontario,Canada /Meteo/Villes/can/Pages/CAON0640.htm
		Saint-Clet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0564.htm
		Saint-Côme,Québec,Canada /Meteo/Villes/can/Pages/CAQC0112.htm
		Saint-Côme-de-Kennebec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0501.htm
		Saint-Constant,Québec,Canada /Meteo/Villes/can/Pages/CAQC0565.htm
		Saint-Cyrille-de-Wendover,Québec,Canada /Meteo/Villes/can/Pages/CAQC0566.htm
		Saint-Damase,Québec,Canada /Meteo/Villes/can/Pages/CAQC0567.htm
		Saint-Damien-de-Buckland,Québec,Canada /Meteo/Villes/can/Pages/CAQC0568.htm
		Saint-Denis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0569.htm
		Saint-Donat,Québec,Canada /Meteo/Villes/can/Pages/CAQC0570.htm
		Saint-Édouard-de-Frampton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0502.htm
		Saint-Édouard-de-Lotbinière,Québec,Canada /Meteo/Villes/can/Pages/CAQC0571.htm
		Saint-Éleuthère,Québec,Canada /Meteo/Villes/can/Pages/CAQC0572.htm
		Saint-Élie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0187.htm
		{Saint-Élie-d'Orford (Sherbrooke),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0167.htm
		{Saint-Émile (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0573.htm
		Saint-Émile-de-Suffolk,Québec,Canada /Meteo/Villes/can/Pages/CAQC0574.htm
		Saint-Éphrem-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0575.htm
		Saint-Éphrem-de-Tring,Québec,Canada /Meteo/Villes/can/Pages/CAQC0576.htm
		Saint-Eugène,Ontario,Canada /Meteo/Villes/can/Pages/CAON0648.htm
		Saint-Eugène-de-Guigues,Québec,Canada /Meteo/Villes/can/Pages/CAQC0577.htm
		Saint-Eustache,Québec,Canada /Meteo/Villes/can/Pages/CAQC0578.htm
		Saint-Fabien-de-Panet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0579.htm
		Saint-Fabien-de-Rimouski,Québec,Canada /Meteo/Villes/can/Pages/CAQC0503.htm
		Saint-Félicien,Québec,Canada /Meteo/Villes/can/Pages/CAQC0580.htm
		Saint-Félix-d'Otis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0938.htm
		Saint-Félix-de-Kingsey,Québec,Canada /Meteo/Villes/can/Pages/CAQC0581.htm
		Saint-Félix-de-Valois,Québec,Canada /Meteo/Villes/can/Pages/CAQC0582.htm
		Saint-Ferdinand,Québec,Canada /Meteo/Villes/can/Pages/CAQC0049.htm
		Saint-Ferdinand-d'Halifax,Québec,Canada /Meteo/Villes/can/Pages/CAQC0505.htm
		Saint-Ferréol-les-neiges,Québec,Canada /Meteo/Villes/can/Pages/CAQC1241.htm
		Saint-Fidèle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0507.htm
		Saint-Fidèle-de-Mont-Murray,Québec,Canada /Meteo/Villes/can/Pages/CAQC0583.htm
		Saint-Flavien,Québec,Canada /Meteo/Villes/can/Pages/CAQC0584.htm
		{Saint-François Xavier,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0202.htm
		Saint-François-du-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0585.htm
		Saint-Fulgence,Québec,Canada /Meteo/Villes/can/Pages/CAQC0586.htm
		Saint-Gabriel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0587.htm
		Saint-Gabriel-de-Brandon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0588.htm
		Saint-Gabriel-de-Rimouski,Québec,Canada /Meteo/Villes/can/Pages/CAQC0509.htm
		Saint-Gédéon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0589.htm
		Saint-Gédéon-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0510.htm
		Saint-George,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0093.htm
		Saint-George,Ontario,Canada /Meteo/Villes/can/Pages/CAON0641.htm
		{Saint-George's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0251.htm
		{Saint-Georges (Shawinigan),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0590.htm
		Saint-Georges-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0591.htm
		Saint-Georges-de-Cacouna,Québec,Canada /Meteo/Villes/can/Pages/CAQC0592.htm
		Saint-Gérard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0593.htm
		Saint-Germain-de-Grantham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0594.htm
		Saint-Grégoire-de-Greenlay,Québec,Canada /Meteo/Villes/can/Pages/CAQC0595.htm
		Saint-Grégoire-de-Nicolet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0511.htm
		Saint-Gregor,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0298.htm
		Saint-Guillaume,Québec,Canada /Meteo/Villes/can/Pages/CAQC0596.htm
		Saint-Henri-de-Lévis,Québec,Canada /Meteo/Villes/can/Pages/CAQC0512.htm
		Saint-Hilarion,Québec,Canada /Meteo/Villes/can/Pages/CAQC0597.htm
		Saint-Hippolyte,Québec,Canada /Meteo/Villes/can/Pages/CAQC0598.htm
		Saint-Honoré,Québec,Canada /Meteo/Villes/can/Pages/CAQC0513.htm
		Saint-Honoré-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0599.htm
		Saint-Honoré-de-Chicoutimi,Québec,Canada /Meteo/Villes/can/Pages/CAQC0600.htm
		Saint-Hubert,Québec,Canada /Meteo/Villes/can/Pages/CAQC0601.htm
		Saint-Hugues,Québec,Canada /Meteo/Villes/can/Pages/CAQC0602.htm
		Saint-Hyacinthe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0603.htm
		Saint-Irénée,Québec,Canada /Meteo/Villes/can/Pages/CAQC0604.htm
		{Saint-Isidore de Prescott,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0642.htm
		Saint-Isidore,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0099.htm
		Saint-Jacobs,Ontario,Canada /Meteo/Villes/can/Pages/CAON0643.htm
		Saint-Jacques,Québec,Canada /Meteo/Villes/can/Pages/CAQC0605.htm
		{Saint-Jacques-Coomb's Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0252.htm
		{Saint-Jean-Chrysostome (Lévis),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0606.htm
		Saint-Jean-Port-Joli,Québec,Canada /Meteo/Villes/can/Pages/CAQC0609.htm
		Saint-Jean-de-Dieu,Québec,Canada /Meteo/Villes/can/Pages/CAQC0607.htm
		Saint-Jean-de-Matha,Québec,Canada /Meteo/Villes/can/Pages/CAQC0608.htm
		Saint-Jean-sur-Richelieu,Québec,Canada /Meteo/Villes/can/Pages/CAQC0610.htm
		Saint-Jérôme,Québec,Canada /Meteo/Villes/can/Pages/CAQC0611.htm
		{Saint-John's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0253.htm
		Saint-Joseph-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0612.htm
		Saint-Joseph-de-Sorel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0614.htm
		{Saint-Joseph-de-la-Rive (Les Éboulements),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0613.htm
		Saint-Jovite,Québec,Canada /Meteo/Villes/can/Pages/CAQC0615.htm
		Saint-Jude,Québec,Canada /Meteo/Villes/can/Pages/CAQC0616.htm
		Saint-Just-de-Bretenières,Québec,Canada /Meteo/Villes/can/Pages/CAQC0617.htm
		{Saint-Lambert (Longueuil),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0618.htm
		Saint-Lambert-de-Lauzon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0619.htm
		{Saint-Laurent (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0620.htm
		Saint-Laurent,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0204.htm
		{Saint-Lawrence,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0254.htm
		Saint-Lazare,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0205.htm
		Saint-Léon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0801.htm
		Saint-Léon-de-Standon,Québec,Canada /Meteo/Villes/can/Pages/CAQC1031.htm
		Saint-Léon-le-Grand,Québec,Canada /Meteo/Villes/can/Pages/CAQC0621.htm
		{Saint-Léonard (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0622.htm
		Saint-Leonard,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0094.htm
		Saint-Léonard-d'Aston,Québec,Canada /Meteo/Villes/can/Pages/CAQC0623.htm
		{Saint-Lewis,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0255.htm
		Saint-Liboire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0624.htm
		Saint-Lin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0625.htm
		{Saint-Louis de Kent,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0100.htm
		Saint-Louis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0299.htm
		{Saint-Louis-de-France (Trois-Rivières),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0626.htm
		Saint-Luc,Québec,Canada /Meteo/Villes/can/Pages/CAQC0627.htm
		Saint-Ludger,Québec,Canada /Meteo/Villes/can/Pages/CAQC0628.htm
		{Saint-Lunaire-Griquet,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0256.htm
		Saint-Magloire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0629.htm
		Saint-Malachie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0630.htm
		Saint-Malo,Québec,Canada /Meteo/Villes/can/Pages/CAQC0631.htm
		Saint-Marc-des-Carrières,Québec,Canada /Meteo/Villes/can/Pages/CAQC0632.htm
		{Saint-Margaret Village,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0139.htm
		Saint-Martin-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0517.htm
		Saint-Martins,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0095.htm
		{Saint-Mary's,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0257.htm
		Saint-Marys,Ontario,Canada /Meteo/Villes/can/Pages/CAON0645.htm
		Saint-Méthode-de-Frontenac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0633.htm
		Saint-Michael,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0285.htm
		Saint-Michel-de-Bellechasse,Québec,Canada /Meteo/Villes/can/Pages/CAQC0634.htm
		Saint-Michel-des-Saints,Québec,Canada /Meteo/Villes/can/Pages/CAQC0520.htm
		Saint-Moise,Québec,Canada /Meteo/Villes/can/Pages/CAQC0521.htm
		Saint-Moose,Québec,Canada /Meteo/Villes/can/Pages/CAQC0635.htm
		Saint-Nazaire-d'Acton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0636.htm
		{Saint-Nicolas (Lévis),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0637.htm
		Saint-Noël,Québec,Canada /Meteo/Villes/can/Pages/CAQC0638.htm
		Saint-Odilon-de-Cranbourne,Québec,Canada /Meteo/Villes/can/Pages/CAQC0639.htm
		Saint-Ours,Québec,Canada /Meteo/Villes/can/Pages/CAQC0640.htm
		Saint-Pacôme,Québec,Canada /Meteo/Villes/can/Pages/CAQC0641.htm
		Saint-Pamphile,Québec,Canada /Meteo/Villes/can/Pages/CAQC0642.htm
		Saint-Pascal,Québec,Canada /Meteo/Villes/can/Pages/CAQC0643.htm
		Saint-Patrice-de-Beaurivage,Québec,Canada /Meteo/Villes/can/Pages/CAQC0644.htm
		Saint-Paul,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0286.htm
		Saint-Paul-d'Abbotsford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0645.htm
		Saint-Paul-de-Montminy,Québec,Canada /Meteo/Villes/can/Pages/CAQC0646.htm
		Saint-Paulin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0647.htm
		Saint-Peter's,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0141.htm
		Saint-Peters,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0029.htm
		Saint-Philippe-de-Néri,Québec,Canada /Meteo/Villes/can/Pages/CAQC0648.htm
		Saint-Pie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0649.htm
		Saint-Pie-de-Guire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0650.htm
		Saint-Pierre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0651.htm
		Saint-Pierre-Jolys,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0208.htm
		Saint-Pierre-de-Wakefield,Québec,Canada /Meteo/Villes/can/Pages/CAQC0652.htm
		Saint-Pierre-les-Becquets,Québec,Canada /Meteo/Villes/can/Pages/CAQC0653.htm
		Saint-Polycarpe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0654.htm
		Saint-Prime,Québec,Canada /Meteo/Villes/can/Pages/CAQC0655.htm
		Saint-Prosper-de-Dorchester,Québec,Canada /Meteo/Villes/can/Pages/CAQC0656.htm
		Saint-Quentin,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0101.htm
		Saint-Raphaël-de-Bellechasse,Québec,Canada /Meteo/Villes/can/Pages/CAQC0524.htm
		Saint-Raymond,Québec,Canada /Meteo/Villes/can/Pages/CAQC0657.htm
		{Saint-Rédempteur (Lévis),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0658.htm
		Saint-Regis,Ontario,Canada /Meteo/Villes/can/Pages/CAON0646.htm
		Saint-Rémi,Québec,Canada /Meteo/Villes/can/Pages/CAQC0659.htm
		Saint-René-de-Matane,Québec,Canada /Meteo/Villes/can/Pages/CAQC0660.htm
		Saint-Roch-de-Mékinac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0661.htm
		Saint-Roch-des-Aulnaies,Québec,Canada /Meteo/Villes/can/Pages/CAQC0662.htm
		{Saint-Romuald (Lévis),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0663.htm
		Saint-Sauveur,Québec,Canada /Meteo/Villes/can/Pages/CAQC0664.htm
		Saint-Sauveur-des-Monts,Québec,Canada /Meteo/Villes/can/Pages/CAQC0665.htm
		Saint-Sébastien,Québec,Canada /Meteo/Villes/can/Pages/CAQC0525.htm
		Saint-Siméon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0666.htm
		Saint-Simon-de-Bagot,Québec,Canada /Meteo/Villes/can/Pages/CAQC0667.htm
		Saint-Simon-de-Rimouski,Québec,Canada /Meteo/Villes/can/Pages/CAQC0668.htm
		Saint-Stanislas-de-Champlain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0526.htm
		Saint-Stephen,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0096.htm
		Saint-Sylvère,Québec,Canada /Meteo/Villes/can/Pages/CAQC0669.htm
		Saint-Sylvestre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0670.htm
		Saint-Théophile,Québec,Canada /Meteo/Villes/can/Pages/CAQC0671.htm
		Saint-Thomas,Ontario,Canada /Meteo/Villes/can/Pages/CAON0647.htm
		Saint-Thomas-d'Aquin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0672.htm
		Saint-Timothée,Québec,Canada /Meteo/Villes/can/Pages/CAQC0673.htm
		Saint-Tite,Québec,Canada /Meteo/Villes/can/Pages/CAQC0674.htm
		Saint-Tite-des-Caps,Québec,Canada /Meteo/Villes/can/Pages/CAQC0675.htm
		Saint-Ubalde,Québec,Canada /Meteo/Villes/can/Pages/CAQC0676.htm
		Saint-Ulric,Québec,Canada /Meteo/Villes/can/Pages/CAQC0677.htm
		Saint-Urbain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0678.htm
		{Saint-Valérien ,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1026.htm
		Saint-Victor,Québec,Canada /Meteo/Villes/can/Pages/CAQC0679.htm
		Saint-Victor-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0528.htm
		{Saint-Vincent's-St. Stephen's-Peter's River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0258.htm
		Saint-Vincent-de-Paul,Québec,Canada /Meteo/Villes/can/Pages/CAQC0529.htm
		Saint-Walburg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0300.htm
		Saint-Wenceslas,Québec,Canada /Meteo/Villes/can/Pages/CAQC0680.htm
		Saint-Zacharie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0681.htm
		Saint-Zénon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0682.htm
		Saint-Zéphirin,Québec,Canada /Meteo/Villes/can/Pages/CAQC0683.htm
		Saint-Zotique,Québec,Canada /Meteo/Villes/can/Pages/CAQC0684.htm
		{Sainte Angele De Monnoir,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1266.htm
		{Sainte Brigide D'Iberville,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1268.htm
		{Sainte Cecile De Milton,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1269.htm
		{Sainte Famille,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1271.htm
		{Sainte Marie Salome,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1272.htm
		{Sainte Marthe Du Cap,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1273.htm
		{Sainte Sophie,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1274.htm
		{Sainte Thérèse De Blainville,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1278.htm
		Sainte-Adèle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0696.htm
		Sainte-Agathe,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0210.htm
		Sainte-Agathe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0697.htm
		Sainte-Agathe-Sud,Québec,Canada /Meteo/Villes/can/Pages/CAQC0699.htm
		Sainte-Agathe-de-Lotbinière,Québec,Canada /Meteo/Villes/can/Pages/CAQC0686.htm
		Sainte-Agathe-des-Monts,Québec,Canada /Meteo/Villes/can/Pages/CAQC0698.htm
		Sainte-Angèle-de-Laval,Québec,Canada /Meteo/Villes/can/Pages/CAQC0687.htm
		Sainte-Anne-de-Beaupré,Québec,Canada /Meteo/Villes/can/Pages/CAQC0700.htm
		{Sainte-Anne-de-Bellevue (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0701.htm
		Sainte-Anne-de-Madawaska,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0103.htm
		Sainte-Anne-de-Portneuf,Québec,Canada /Meteo/Villes/can/Pages/CAQC0703.htm
		Sainte-Anne-de-Sorel,Québec,Canada /Meteo/Villes/can/Pages/CAQC1267.htm
		Sainte-Anne-de-la-Pérade,Québec,Canada /Meteo/Villes/can/Pages/CAQC0702.htm
		Sainte-Anne-des-Monts,Québec,Canada /Meteo/Villes/can/Pages/CAQC0704.htm
		Sainte-Anne-des-Plaines,Québec,Canada /Meteo/Villes/can/Pages/CAQC0705.htm
		Sainte-Anne-du-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0706.htm
		{Sainte-Blandine (Rimouski),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0707.htm
		Sainte-Brigitte-de-Laval,Québec,Canada /Meteo/Villes/can/Pages/CAQC0708.htm
		Sainte-Catherine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0709.htm
		Sainte-Catherine-de-la-Jacques-Cartier,Québec,Canada /Meteo/Villes/can/Pages/CAQC1116.htm
		Sainte-Cécile-de-Masham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0688.htm
		Sainte-Claire-de-Dorchester,Québec,Canada /Meteo/Villes/can/Pages/CAQC0689.htm
		Sainte-Clotilde-de-Horton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0710.htm
		Sainte-Croix-de-Lotbinière,Québec,Canada /Meteo/Villes/can/Pages/CAQC0690.htm
		Sainte-Dorothée,Québec,Canada /Meteo/Villes/can/Pages/CAQC1270.htm
		Sainte-Eulalie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0712.htm
		Sainte-Félicité,Québec,Canada /Meteo/Villes/can/Pages/CAQC0713.htm
		{Sainte-Foy (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0714.htm
		{Sainte-Geneviève (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0715.htm
		Sainte-Gertrude,Québec,Canada /Meteo/Villes/can/Pages/CAQC0691.htm
		Sainte-Hélène-de-Bagot,Québec,Canada /Meteo/Villes/can/Pages/CAQC0716.htm
		Sainte-Hénédine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0717.htm
		Sainte-Jeanne-d'Arc,Québec,Canada /Meteo/Villes/can/Pages/CAQC0718.htm
		Sainte-Julie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0719.htm
		Sainte-Julie-de-Verchères,Québec,Canada /Meteo/Villes/can/Pages/CAQC0720.htm
		Sainte-Julienne,Québec,Canada /Meteo/Villes/can/Pages/CAQC0721.htm
		Sainte-Justine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0722.htm
		Sainte-Justine-de-Newton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0692.htm
		Sainte-Luce-Luceville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0321.htm
		Sainte-Lucie-de-Beauregard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0723.htm
		Sainte-Madeleine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0724.htm
		Sainte-Marguerite,Québec,Canada /Meteo/Villes/can/Pages/CAQC0725.htm
		Sainte-Marguerite-Estérel,Québec,Canada /Meteo/Villes/can/Pages/CAQC0158.htm
		Sainte-Marie-de-Beauce,Québec,Canada /Meteo/Villes/can/Pages/CAQC0726.htm
		Sainte-Marie-de-Blandford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0727.htm
		Sainte-Marthe,Québec,Canada /Meteo/Villes/can/Pages/CAQC0728.htm
		Sainte-Marthe-sur-le-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0729.htm
		Sainte-Martine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0693.htm
		Sainte-Méthode-de-Frontenac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0694.htm
		Sainte-Monique-de-Nicolet,Québec,Canada /Meteo/Villes/can/Pages/CAQC0695.htm
		Sainte-Perpétue,Québec,Canada /Meteo/Villes/can/Pages/CAQC0730.htm
		Sainte-Pétronille,Québec,Canada /Meteo/Villes/can/Pages/CAQC0731.htm
		Sainte-Rosalie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0732.htm
		{Sainte-Rose du Lac,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0212.htm
		Sainte-Rose,Québec,Canada /Meteo/Villes/can/Pages/CAQC0733.htm
		Sainte-Rose-de-Watford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0734.htm
		Sainte-Rose-du-Nord,Québec,Canada /Meteo/Villes/can/Pages/CAQC0735.htm
		Sainte-Sophie-de-Lévrard,Québec,Canada /Meteo/Villes/can/Pages/CAQC0736.htm
		Sainte-Thècle,Québec,Canada /Meteo/Villes/can/Pages/CAQC0737.htm
		Sainte-Thérèse-d'Avila,Québec,Canada /Meteo/Villes/can/Pages/CAQC0738.htm
		Sainte-Véronique,Québec,Canada /Meteo/Villes/can/Pages/CAQC0739.htm
		Sainte-Victoire,Québec,Canada /Meteo/Villes/can/Pages/CAQC0740.htm
		Sainte-Victoire-de-Sorel,Québec,Canada /Meteo/Villes/can/Pages/CAQC1279.htm
		Salaberry-de-Valleyfield,Québec,Canada /Meteo/Villes/can/Pages/CAQC0474.htm
		Salem,Ontario,Canada /Meteo/Villes/can/Pages/CAON1756.htm
		Salisbury,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0089.htm
		Salluit,Québec,Canada /Meteo/Villes/can/Pages/CAQC0475.htm
		{Salmon Arm,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0258.htm
		{Salmon Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0233.htm
		{Salmon Valley,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0259.htm
		Salmo,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0257.htm
		{Salt Springs,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0127.htm
		Saltcoats,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0274.htm
		{Salvage,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0234.htm
		Sandspit,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0260.htm
		Sandwich,Ontario,Canada /Meteo/Villes/can/Pages/CAON1746.htm
		{Sandy Bay,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0275.htm
		{Sandy Cove Acres,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1759.htm
		{Sandy Lake First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1581.htm
		{Sandy Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0181.htm
		{Sandy Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0599.htm
		Sanford,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0182.htm
		Sangudo,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0268.htm
		Sanmaur,Québec,Canada /Meteo/Villes/can/Pages/CAQC0476.htm
		Sapawe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0600.htm
		Sarnia,Ontario,Canada /Meteo/Villes/can/Pages/CAON0601.htm
		{Saskatchewan River Crossing,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0269.htm
		Saskatoon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0276.htm
		{Sauble Beach,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0602.htm
		{Saugeen First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1560.htm
		Saulnierville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0130.htm
		{Sault Ste Marie,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0603.htm
		Sault-au-Mouton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0477.htm
		{Savant Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0604.htm
		Savona,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0262.htm
		Sayabec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0479.htm
		Sayward,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0263.htm
		Scarborough,Ontario,Canada /Meteo/Villes/can/Pages/CAON0605.htm
		Sceptre,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0277.htm
		Schefferville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0480.htm
		Schomberg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0606.htm
		Schreiber,Ontario,Canada /Meteo/Villes/can/Pages/CAON0607.htm
		Schuler,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0270.htm
		Scotland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0608.htm
		Scotstown,Québec,Canada /Meteo/Villes/can/Pages/CAQC0481.htm
		Scott,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0278.htm
		Seaforth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0609.htm
		{Seal Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0235.htm
		Searchmont,Ontario,Canada /Meteo/Villes/can/Pages/CAON0610.htm
		{Seba Beach,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0271.htm
		Sebright,Ontario,Canada /Meteo/Villes/can/Pages/CAON0611.htm
		Sebringville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0612.htm
		Sechelt,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0264.htm
		Sedgewick,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0272.htm
		Sedley,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0279.htm
		{Seeleys Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0613.htm
		Selby,Ontario,Canada /Meteo/Villes/can/Pages/CAON0614.htm
		{Seldom-Little Seldom,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0236.htm
		Selkirk,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0183.htm
		Selkirk,Ontario,Canada /Meteo/Villes/can/Pages/CAON0615.htm
		Semans,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0280.htm
		Senneterre,Québec,Canada /Meteo/Villes/can/Pages/CAQC0482.htm
		{Senneville (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0483.htm
		Sept-Îles,Québec,Canada /Meteo/Villes/can/Pages/CAQC0484.htm
		{Serpent River First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1474.htm
		{Seven Persons,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0273.htm
		{Severn Bridge,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0616.htm
		Sexsmith,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0274.htm
		Shakespeare,Ontario,Canada /Meteo/Villes/can/Pages/CAON0617.htm
		Shalalth,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0265.htm
		Shamattawa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0184.htm
		Shannonville,Ontario,Canada /Meteo/Villes/can/Pages/CAON1747.htm
		{Sharbot Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0618.htm
		Shaunavon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0281.htm
		{Shawanaga First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1480.htm
		Shawbridge,Québec,Canada /Meteo/Villes/can/Pages/CAQC0485.htm
		Shawinigan-Sud,Québec,Canada /Meteo/Villes/can/Pages/CAQC0487.htm
		Shawinigan,Québec,Canada /Meteo/Villes/can/Pages/CAQC0486.htm
		Shawville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0488.htm
		Shebandowan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0619.htm
		Shedden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0620.htm
		Shediac,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0090.htm
		Shefford,Québec,Canada /Meteo/Villes/can/Pages/CAQC1192.htm
		Sheho,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0282.htm
		Shelburne,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0132.htm
		Shelburne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0621.htm
		{Shell Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0283.htm
		Shellbrook,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0284.htm
		Sherbrooke,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0133.htm
		Sherbrooke,Québec,Canada /Meteo/Villes/can/Pages/CAQC0489.htm
		{Sherwood Park,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0275.htm
		Shigawake,Québec,Canada /Meteo/Villes/can/Pages/CAQC0780.htm
		Shilo,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0186.htm
		Shippagan,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0091.htm
		Shipshaw,Québec,Canada /Meteo/Villes/can/Pages/CAQC1275.htm
		{Shoal Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0187.htm
		Shubenacadie,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0134.htm
		Sibbald,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0276.htm
		Sicamous,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0266.htm
		Sidney,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0267.htm
		Sidney,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0188.htm
		Sifton,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0189.htm
		{Sillery (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0490.htm
		{Silver Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0277.htm
		{Silver Water,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0622.htm
		Simcoe,Ontario,Canada /Meteo/Villes/can/Pages/CAON0623.htm
		Simpson,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0285.htm
		Sintaluta,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0286.htm
		{Sioux Lookout,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0624.htm
		{Sioux Narrows,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0625.htm
		{Six Nations of the Grand River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1477.htm
		Skookumchuck,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0268.htm
		{Slave Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0278.htm
		Slocan,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0269.htm
		{Small Point-Broad Cove-Blackhead-Adams C,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0237.htm
		Smeaton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0287.htm
		Smiley,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0288.htm
		Smithers,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0270.htm
		{Smiths Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0626.htm
		Smithville,Ontario,Canada /Meteo/Villes/can/Pages/CAON1748.htm
		Smith,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0279.htm
		{Smoky Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0280.htm
		{Smooth Rock Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0627.htm
		Snag,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0027.htm
		Snelgrove,Ontario,Canada /Meteo/Villes/can/Pages/CAON0628.htm
		{Snow Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0191.htm
		Snowflake,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0192.htm
		Sointula,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0271.htm
		Sombra,Ontario,Canada /Meteo/Villes/can/Pages/CAON0629.htm
		Somerset,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0193.htm
		Sooke,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0272.htm
		Sorel-Tracy,Québec,Canada /Meteo/Villes/can/Pages/CAQC0491.htm
		Sorrento,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0273.htm
		Souris,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0021.htm
		Souris,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0194.htm
		{South Brook,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0240.htm
		{South Indian Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0195.htm
		{South Lake,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0022.htm
		{South Mountain,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0630.htm
		{South River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0632.htm
		{South River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0241.htm
		{South Slocan,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0274.htm
		Southampton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0135.htm
		Southampton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0633.htm
		Southend,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0289.htm
		{Southern Harbour,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0242.htm
		Southey,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0290.htm
		Spalding,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0291.htm
		{Spaniard's Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0243.htm
		Spanish,Ontario,Canada /Meteo/Villes/can/Pages/CAON0634.htm
		Sparta,Ontario,Canada /Meteo/Villes/can/Pages/CAON0635.htm
		Sparwood,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0275.htm
		Speers,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0292.htm
		Spencerville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0636.htm
		{Spences Bridge,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0276.htm
		Sperling,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0197.htm
		Spillimacheen,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0278.htm
		{Spirit River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0281.htm
		Spiritwood,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0293.htm
		{Split Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0198.htm
		{Spotted Island,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0244.htm
		Sprague,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0199.htm
		{Springdale,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0245.htm
		Springfield,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0092.htm
		Springfield,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0136.htm
		Springhill,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0137.htm
		Springside,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0294.htm
		{Spruce Grove,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0282.htm
		{Spruce View,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0283.htm
		Sprucedale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0637.htm
		{Spy Hill,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0295.htm
		Squamish,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0279.htm
		Squatec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0493.htm
		{St. Davids,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1757.htm
		{St. Jean Baptiste,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0328.htm
		{St. Margaret's Bay,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0308.htm
		{Stand Off,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0287.htm
		Standard,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0288.htm
		{Stanley Mission,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0301.htm
		Stanley,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0102.htm
		Stanstead,Québec,Canada /Meteo/Villes/can/Pages/CAQC0685.htm
		{Star City,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0302.htm
		Starbuck,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0209.htm
		Stavely,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0289.htm
		Stayner,Ontario,Canada /Meteo/Villes/can/Pages/CAON0649.htm
		{Steady Brook,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0259.htm
		{Steep Rock,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0214.htm
		Steinbach,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0215.htm
		Stellarton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0142.htm
		{Stephenville Crossing,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0261.htm
		{Stephenville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0260.htm
		Stettler,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0290.htm
		Stevensville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0650.htm
		Stewarttown,Ontario,Canada /Meteo/Villes/can/Pages/CAON1750.htm
		Stewart,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0281.htm
		Stewiacke,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0143.htm
		Stirling,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0291.htm
		Stirling,Ontario,Canada /Meteo/Villes/can/Pages/CAON0651.htm
		Stockholm,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0303.htm
		{Stoke's Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0653.htm
		Stoke,Québec,Canada /Meteo/Villes/can/Pages/CAQC0741.htm
		Stoneham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0742.htm
		Stonewall,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0217.htm
		{Stoney Creek,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0654.htm
		{Stoney Point,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0655.htm
		{Stony Plain,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0292.htm
		{Stony Rapids,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0304.htm
		Storthoaks,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0305.htm
		Stouffville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0656.htm
		Stoughton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0306.htm
		Straffordville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0657.htm
		Strasbourg,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0307.htm
		Stratford,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0023.htm
		Stratford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0658.htm
		Stratford,Québec,Canada /Meteo/Villes/can/Pages/CAQC0743.htm
		Strathclair,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0219.htm
		Strathmore,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0293.htm
		Strathroy,Ontario,Canada /Meteo/Villes/can/Pages/CAON0659.htm
		Stratton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0660.htm
		Streetsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0661.htm
		Strome,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0294.htm
		Strongfield,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0308.htm
		Stroud,Ontario,Canada /Meteo/Villes/can/Pages/CAON0662.htm
		{Stukely (Eastman),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0744.htm
		{Sturgeon Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0663.htm
		Sturgis,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0309.htm
		Sudbury,Ontario,Canada /Meteo/Villes/can/Pages/CAON0664.htm
		Sultan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0665.htm
		{Summer Beaver,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0666.htm
		{Summerford,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0262.htm
		Summerland,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0282.htm
		Summerside,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0024.htm
		{Summerside,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0263.htm
		Summerville,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0104.htm
		{Summit Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0283.htm
		{Sun Peaks,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0339.htm
		Sunderland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0667.htm
		Sundre,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0296.htm
		Sundridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0668.htm
		{Sunnyside,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0264.htm
		Surrey,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0284.htm
		Sussex,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0105.htm
		Sutton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0669.htm
		Sutton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0745.htm
		{Swan Hills,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0297.htm
		{Swan Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0221.htm
		{Swan River,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0222.htm
		Swastika,Ontario,Canada /Meteo/Villes/can/Pages/CAON0670.htm
		{Swift Current,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0310.htm
		{Swift River,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0015.htm
		Sydenham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0671.htm
		Sydney,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0145.htm
		{Sylvan Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0298.htm
		Taber,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0299.htm
		Tabusintac,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0106.htm
		Tachie,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0285.htm
		{Tadoule Lake,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0223.htm
		Tadoussac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0746.htm
		Tagish,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0016.htm
		Tahsis,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0286.htm
		Tamworth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0672.htm
		Tangier,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0147.htm
		Tantallon,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0311.htm
		Tara,Ontario,Canada /Meteo/Villes/can/Pages/CAON0673.htm
		Taschereau,Québec,Canada /Meteo/Villes/can/Pages/CAQC0747.htm
		Tasiujaq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0748.htm
		Tatamagouche,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0148.htm
		{Tatla Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0288.htm
		Tavistock,Ontario,Canada /Meteo/Villes/can/Pages/CAON0674.htm
		{Taylor Corners,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1751.htm
		Taylor,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0289.htm
		Tecumseh,Ontario,Canada /Meteo/Villes/can/Pages/CAON0675.htm
		Teeswater,Ontario,Canada /Meteo/Villes/can/Pages/CAON0676.htm
		{Telegraph Creek,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0290.htm
		Telkwa,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0291.htm
		Temagami,Ontario,Canada /Meteo/Villes/can/Pages/CAON0677.htm
		Témiscaming,Québec,Canada /Meteo/Villes/can/Pages/CAQC0749.htm
		{Temiskaming Shores,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0541.htm
		{Terra Nova,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0265.htm
		{Terrace Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0678.htm
		Terrace,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0292.htm
		{Terrasse Vaudreuil,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1280.htm
		{Terrebonne (La Plaine),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0255.htm
		{Terrebonne (Lachenaie),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0280.htm
		Terrebonne,Québec,Canada /Meteo/Villes/can/Pages/CAQC0750.htm
		{Terrenceville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0266.htm
		Teslin,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0017.htm
		Tête-à-la-Baleine,Québec,Canada /Meteo/Villes/can/Pages/CAQC0751.htm
		Teulon,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0224.htm
		Thamesford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0679.htm
		Thamesville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0680.htm
		{The Eabametoong (Fort Hope) First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1510.htm
		{The Pas,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0225.htm
		Thedford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0681.htm
		Theodore,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0312.htm
		{Thessalon First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1562.htm
		Thessalon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0682.htm
		{Thetford Mines,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0752.htm
		{Thicket Portage,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0226.htm
		Thompson,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0227.htm
		Thorburn,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0149.htm
		Thorhild,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0300.htm
		Thornbury,Ontario,Canada /Meteo/Villes/can/Pages/CAON0683.htm
		Thorndale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0684.htm
		Thorne,Ontario,Canada /Meteo/Villes/can/Pages/CAON0685.htm
		Thornhill,Ontario,Canada /Meteo/Villes/can/Pages/CAON0686.htm
		Thorold,Ontario,Canada /Meteo/Villes/can/Pages/CAON0687.htm
		Thorsby,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0301.htm
		{Three Hills,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0302.htm
		Thrums,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0293.htm
		{Thunder Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0688.htm
		Thurlow,Ontario,Canada /Meteo/Villes/can/Pages/CAON0689.htm
		Thurso,Québec,Canada /Meteo/Villes/can/Pages/CAQC0753.htm
		Tignish,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0025.htm
		Tilbury,Ontario,Canada /Meteo/Villes/can/Pages/CAON0690.htm
		Tilley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0303.htm
		Tillsonburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0691.htm
		Timmins,Ontario,Canada /Meteo/Villes/can/Pages/CAON0692.htm
		Tingwick,Québec,Canada /Meteo/Villes/can/Pages/CAQC0754.htm
		Tisdale,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0313.htm
		Tiverton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0693.htm
		{Toad River,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0294.htm
		Tobermory,Ontario,Canada /Meteo/Villes/can/Pages/CAON0694.htm
		{Tobique First Nation,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0194.htm
		Tofield,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0304.htm
		Tofino,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0295.htm
		Togo,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0314.htm
		Toledo,Ontario,Canada /Meteo/Villes/can/Pages/CAON0695.htm
		Tomahawk,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0305.htm
		Tompkins,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0315.htm
		Topley,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0296.htm
		{Torbay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0267.htm
		{Toronto Island,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1761.htm
		Toronto,Ontario,Canada /Meteo/Villes/can/Pages/CAON0696.htm
		Torquay,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0316.htm
		Torrington,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0306.htm
		Tottenham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0697.htm
		Tracadie-Sheila,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0107.htm
		Trail,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0297.htm
		{Tramping Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0317.htm
		Treherne,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0229.htm
		Tremblay,Québec,Canada /Meteo/Villes/can/Pages/CAQC1193.htm
		Trenton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0150.htm
		Trenton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0698.htm
		{Trepassey,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0268.htm
		Tribune,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0318.htm
		Tring-Jonction,Québec,Canada /Meteo/Villes/can/Pages/CAQC0757.htm
		{Triton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0269.htm
		Trochu,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0307.htm
		Trois-Pistoles,Québec,Canada /Meteo/Villes/can/Pages/CAQC0758.htm
		Trois-Rivières,Québec,Canada /Meteo/Villes/can/Pages/CAQC0759.htm
		{Trout Creek,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0699.htm
		{Trout Lake,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0308.htm
		{Trout Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0298.htm
		{Trout Lake,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0026.htm
		{Trout River,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0270.htm
		Trowbridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0700.htm
		Truro,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0151.htm
		{Tsay Keh Dene,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0299.htm
		{Tsiigehtchic,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0027.htm
		{Tuktoyaktuk,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0028.htm
		{Tumbler Ridge,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0301.htm
		{Turner Valley,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0309.htm
		{Turnor Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0319.htm
		Turtleford,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0320.htm
		Tusket,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0152.htm
		Tweed,Ontario,Canada /Meteo/Villes/can/Pages/CAON0701.htm
		{Twillingate,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0271.htm
		{Two Hills,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0310.htm
		{Tyne Valley,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0026.htm
		Ucluelet,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0302.htm
		Udora,Ontario,Canada /Meteo/Villes/can/Pages/CAON0702.htm
		Umiujaq,Québec,Canada /Meteo/Villes/can/Pages/CAQC0760.htm
		Uniondale,Ontario,Canada /Meteo/Villes/can/Pages/CAON0703.htm
		Unionville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0704.htm
		Unity,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0321.htm
		{Upper Island Cove,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0272.htm
		{Upper Musquodoboit,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0153.htm
		{Upper Stewiacke,Nouvelle-Écosse,Canada} /Meteo/Villes/can/Pages/CANS0154.htm
		Upsala,Ontario,Canada /Meteo/Villes/can/Pages/CAON0705.htm
		Upton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0761.htm
		{Uranium City,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0322.htm
		Utterson,Ontario,Canada /Meteo/Villes/can/Pages/CAON1752.htm
		Uxbridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0706.htm
		{Val Marie,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0323.htm
		{Val d'Or (Dubuisson),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0146.htm
		Val-Alain,Québec,Canada /Meteo/Villes/can/Pages/CAQC0763.htm
		Val-Barrette,Québec,Canada /Meteo/Villes/can/Pages/CAQC0764.htm
		{Val-Bélair (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0765.htm
		Val-Brillant,Québec,Canada /Meteo/Villes/can/Pages/CAQC0766.htm
		Val-David,Québec,Canada /Meteo/Villes/can/Pages/CAQC0768.htm
		Val-d'Or,Québec,Canada /Meteo/Villes/can/Pages/CAQC0767.htm
		Val-des-Bois,Québec,Canada /Meteo/Villes/can/Pages/CAQC0769.htm
		Valcartier,Québec,Canada /Meteo/Villes/can/Pages/CAQC0804.htm
		Valcourt,Québec,Canada /Meteo/Villes/can/Pages/CAQC0770.htm
		Valemount,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0304.htm
		Vallée-Jonction,Québec,Canada /Meteo/Villes/can/Pages/CAQC0771.htm
		{Valley East,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0707.htm
		Valleyview,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0311.htm
		Vallican,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0305.htm
		{Van Anda,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0306.htm
		Vancouver,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0308.htm
		Vanderhoof,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0309.htm
		Vanguard,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0324.htm
		{Vanier (Québec),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0772.htm
		Vanier,Ontario,Canada /Meteo/Villes/can/Pages/CAON0708.htm
		{Vankleek Hill,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0709.htm
		Vanscoy,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0424.htm
		Varennes,Québec,Canada /Meteo/Villes/can/Pages/CAQC0773.htm
		{Vaudreuil Dorion,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1281.htm
		Vaudreuil-sur-le-Lac,Québec,Canada /Meteo/Villes/can/Pages/CAQC0775.htm
		Vaudreuil,Québec,Canada /Meteo/Villes/can/Pages/CAQC0774.htm
		Vaughan,Ontario,Canada /Meteo/Villes/can/Pages/CAON0710.htm
		Vauxhall,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0312.htm
		Vavenby,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0311.htm
		Vegreville,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0313.htm
		Venise-en-Québec,Québec,Canada /Meteo/Villes/can/Pages/CAQC0776.htm
		Verchères,Québec,Canada /Meteo/Villes/can/Pages/CAQC0777.htm
		{Verdun (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0778.htm
		{Vermilion Bay,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0711.htm
		Vermilion,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0314.htm
		Verner,Ontario,Canada /Meteo/Villes/can/Pages/CAON0712.htm
		{Vernon River,Île-du-Prince-Édouard,Canada} /Meteo/Villes/can/Pages/CAPE0027.htm
		Vernon,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0312.htm
		Verona,Ontario,Canada /Meteo/Villes/can/Pages/CAON0713.htm
		Veteran,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0315.htm
		Vibank,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0325.htm
		{Victoria (Downtown),Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0402.htm
		Victoriaville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0779.htm
		Victoria,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0313.htm
		Victoria,Ontario,Canada /Meteo/Villes/can/Pages/CAON0714.htm
		{Victoria,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0273.htm
		{View Royal,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0314.htm
		Viking,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0316.htm
		Ville-Marie,Québec,Canada /Meteo/Villes/can/Pages/CAQC0781.htm
		Vilna,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0317.htm
		Vimont,Québec,Canada /Meteo/Villes/can/Pages/CAQC1282.htm
		Vineland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0715.htm
		Virden,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0232.htm
		Virginiatown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0716.htm
		Viscount,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0326.htm
		Vita,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0233.htm
		Vonda,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0327.htm
		Vulcan,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0318.htm
		Waasagomach,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0234.htm
		Wabamun,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0319.htm
		{Wabana,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0274.htm
		Wabasca-Desmarais,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0747.htm
		Wabigoon,Ontario,Canada /Meteo/Villes/can/Pages/CAON0717.htm
		Wabowden,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0235.htm
		{Wabush,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0275.htm
		Wadena,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0328.htm
		Wainfleet,Ontario,Canada /Meteo/Villes/can/Pages/CAON0718.htm
		Wainwright,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0321.htm
		Wakaw,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0329.htm
		Wakefield,Québec,Canada /Meteo/Villes/can/Pages/CAQC0782.htm
		Walden,Ontario,Canada /Meteo/Villes/can/Pages/CAON0719.htm
		Waldheim,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0330.htm
		Walkerton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0720.htm
		Wallaceburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0721.htm
		Wallace,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0155.htm
		Walsh,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0322.htm
		Walton,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0156.htm
		{Wandering River,Alberta,Canada} /Meteo/Villes/can/Pages/CAAB0323.htm
		Wanham,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0324.htm
		Wanless,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0236.htm
		{Wapekeka First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1500.htm
		Wapella,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0331.htm
		Warburg,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0325.htm
		Warden,Québec,Canada /Meteo/Villes/can/Pages/CAQC0783.htm
		Wardsville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0722.htm
		Warkworth,Ontario,Canada /Meteo/Villes/can/Pages/CAON0723.htm
		Warman,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0332.htm
		Warner,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0326.htm
		Warren,Ontario,Canada /Meteo/Villes/can/Pages/CAON0724.htm
		Warspite,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0327.htm
		Warwick,Québec,Canada /Meteo/Villes/can/Pages/CAQC0784.htm
		{Wasaga Beach,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0725.htm
		Wasagaming,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0238.htm
		Waskaganish,Québec,Canada /Meteo/Villes/can/Pages/CAQC0785.htm
		Waskatenau,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0328.htm
		{Waskesiu Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0333.htm
		Waswanipi,Québec,Canada /Meteo/Villes/can/Pages/CAQC0786.htm
		Waterdown,Ontario,Canada /Meteo/Villes/can/Pages/CAON0726.htm
		Waterford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0727.htm
		Waterhen,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0240.htm
		Waterloo,Ontario,Canada /Meteo/Villes/can/Pages/CAON0728.htm
		Waterloo,Québec,Canada /Meteo/Villes/can/Pages/CAQC0787.htm
		Waterville,Québec,Canada /Meteo/Villes/can/Pages/CAQC0788.htm
		Watford,Ontario,Canada /Meteo/Villes/can/Pages/CAON0729.htm
		Watrous,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0334.htm
		{Watson Lake,Yukon,Canada} /Meteo/Villes/can/Pages/CAYT0018.htm
		Watson,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0335.htm
		Waubaushene,Ontario,Canada /Meteo/Villes/can/Pages/CAON0730.htm
		Waverley,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0157.htm
		Wawanesa,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0241.htm
		Wawa,Ontario,Canada /Meteo/Villes/can/Pages/CAON0731.htm
		Wawota,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0336.htm
		Webbwood,Ontario,Canada /Meteo/Villes/can/Pages/CAON0733.htm
		Webb,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0337.htm
		Webequie,Ontario,Canada /Meteo/Villes/can/Pages/CAON0734.htm
		Wedgeport,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0158.htm
		{Weedon Centre,Québec,Canada} /Meteo/Villes/can/Pages/CAQC0790.htm
		Weedon,Québec,Canada /Meteo/Villes/can/Pages/CAQC0789.htm
		Welcome,Ontario,Canada /Meteo/Villes/can/Pages/CAON0735.htm
		Wellandport,Ontario,Canada /Meteo/Villes/can/Pages/CAON0737.htm
		Welland,Ontario,Canada /Meteo/Villes/can/Pages/CAON0736.htm
		Wellesley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0738.htm
		Wellington,Île-du-Prince-Édouard,Canada /Meteo/Villes/can/Pages/CAPE0028.htm
		Wellington,Ontario,Canada /Meteo/Villes/can/Pages/CAON0739.htm
		Wells,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0316.htm
		Welsford,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0108.htm
		Welwyn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0339.htm
		Wembley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0330.htm
		Wemindji,Québec,Canada /Meteo/Villes/can/Pages/CAQC0791.htm
		Wemotaci,Québec,Canada /Meteo/Villes/can/Pages/CAQC1113.htm
		Wendover,Québec,Canada /Meteo/Villes/can/Pages/CAQC1283.htm
		Wentworth-Nord,Québec,Canada /Meteo/Villes/can/Pages/CAQC1308.htm
		{Wesleyville,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0276.htm
		{West Brome,Québec,Canada} /Meteo/Villes/can/Pages/CAQC1284.htm
		{West Guilford,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0740.htm
		{West Lincoln,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0741.htm
		{West Lorne,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0742.htm
		{West Vancouver,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0317.htm
		Westbank,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0318.htm
		Westbury,Québec,Canada /Meteo/Villes/can/Pages/CAQC1194.htm
		{Western Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0277.htm
		Westfield,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0111.htm
		Westlock,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0331.htm
		Westmeath,Ontario,Canada /Meteo/Villes/can/Pages/CAON0743.htm
		{Westmount (Montréal),Québec,Canada} /Meteo/Villes/can/Pages/CAQC0792.htm
		Westport,Ontario,Canada /Meteo/Villes/can/Pages/CAON0744.htm
		{Westport,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0278.htm
		Westree,Ontario,Canada /Meteo/Villes/can/Pages/CAON0745.htm
		Westville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0161.htm
		Westwold,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0320.htm
		Wetaskiwin,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0332.htm
		Weyburn,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0340.htm
		Weymouth,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0162.htm
		{Whale Cove,Nunavut,Canada} /Meteo/Villes/can/Pages/CANU0026.htm
		Wheatley,Ontario,Canada /Meteo/Villes/can/Pages/CAON0746.htm
		Whistler,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0322.htm
		{Whitbourne,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0279.htm
		Whitby,Ontario,Canada /Meteo/Villes/can/Pages/CAON0747.htm
		Whitchurch-Stouffville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0748.htm
		{White Fox,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0341.htm
		{White River,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0750.htm
		{White Rock,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0323.htm
		Whitecourt,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0333.htm
		{Whitefish Falls,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0752.htm
		{Whitefish River First Nation,Ontario,Canada} /Meteo/Villes/can/Pages/CAON1516.htm
		Whitefish,Ontario,Canada /Meteo/Villes/can/Pages/CAON0751.htm
		Whitehorse,Yukon,Canada /Meteo/Villes/can/Pages/CAYT0019.htm
		Whitelaw,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0334.htm
		Whitemouth,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0242.htm
		Whitewood,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0342.htm
		Whitney,Ontario,Canada /Meteo/Villes/can/Pages/CAON0753.htm
		Whycocomagh,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0163.htm
		Wiarton,Ontario,Canada /Meteo/Villes/can/Pages/CAON0754.htm
		Wickham,Québec,Canada /Meteo/Villes/can/Pages/CAQC0793.htm
		Widewater,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0335.htm
		Wikwemikong,Ontario,Canada /Meteo/Villes/can/Pages/CAON0791.htm
		Wilberforce,Ontario,Canada /Meteo/Villes/can/Pages/CAON0755.htm
		Wilcox,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0343.htm
		Wildwood,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0336.htm
		Wilkie,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0344.htm
		{Williams Lake,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0326.htm
		Williamsburg,Ontario,Canada /Meteo/Villes/can/Pages/CAON0756.htm
		Willingdon,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0337.htm
		{Willow Bunch,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0345.htm
		Willowbrook,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0328.htm
		Winchester,Ontario,Canada /Meteo/Villes/can/Pages/CAON0757.htm
		Windermere,Ontario,Canada /Meteo/Villes/can/Pages/CAON0758.htm
		Windsor,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0164.htm
		Windsor,Ontario,Canada /Meteo/Villes/can/Pages/CAON0759.htm
		Windsor,Québec,Canada /Meteo/Villes/can/Pages/CAQC0794.htm
		Windthorst,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0346.htm
		Winfield,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0338.htm
		Winfield,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0329.htm
		Wingham,Ontario,Canada /Meteo/Villes/can/Pages/CAON0760.htm
		Winkler,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0243.htm
		{Winnipeg Beach,Manitoba,Canada} /Meteo/Villes/can/Pages/CAMB0245.htm
		Winnipegosis,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0246.htm
		Winnipeg,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0244.htm
		Winona,Ontario,Canada /Meteo/Villes/can/Pages/CAON0761.htm
		{Winter Harbour,Colombie-Britannique,Canada} /Meteo/Villes/can/Pages/CABC0330.htm
		{Winterton,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0282.htm
		Wiseton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0347.htm
		Wishart,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0348.htm
		{Witless Bay,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0283.htm
		Woburn,Québec,Canada /Meteo/Villes/can/Pages/CAQC0795.htm
		Woking,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0339.htm
		Wolfville,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0165.htm
		{Wollaston Lake,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0349.htm
		Wolseley,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0350.htm
		Wonowon,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0331.htm
		{Wood Mountain,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0351.htm
		Woodbridge,Ontario,Canada /Meteo/Villes/can/Pages/CAON0763.htm
		Woodridge,Manitoba,Canada /Meteo/Villes/can/Pages/CAMB0248.htm
		Woodstock,Nouveau-Brunswick,Canada /Meteo/Villes/can/Pages/CANB0109.htm
		Woodstock,Ontario,Canada /Meteo/Villes/can/Pages/CAON0765.htm
		Woodville,Ontario,Canada /Meteo/Villes/can/Pages/CAON0766.htm
		{Woody Point,Terre-Neuve et Labrador,Canada} /Meteo/Villes/can/Pages/CANF0284.htm
		Wooler,Ontario,Canada /Meteo/Villes/can/Pages/CAON0767.htm
		Worsley,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0340.htm
		Wotton,Québec,Canada /Meteo/Villes/can/Pages/CAQC0796.htm
		Wrentham,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0341.htm
		{Wrigley,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0031.htm
		{Wunnummin Lake,Ontario,Canada} /Meteo/Villes/can/Pages/CAON0768.htm
		Wynndel,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0333.htm
		Wynyard,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0352.htm
		Wyoming,Ontario,Canada /Meteo/Villes/can/Pages/CAON0769.htm
		Yahk,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0334.htm
		Yale,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0335.htm
		Yamachiche,Québec,Canada /Meteo/Villes/can/Pages/CAQC0797.htm
		Yamaska-Est,Québec,Canada /Meteo/Villes/can/Pages/CAQC0799.htm
		Yamaska,Québec,Canada /Meteo/Villes/can/Pages/CAQC0798.htm
		Yarker,Ontario,Canada /Meteo/Villes/can/Pages/CAON0770.htm
		Yarmouth,Nouvelle-Écosse,Canada /Meteo/Villes/can/Pages/CANS0167.htm
		{Yellow Creek,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0353.htm
		{Yellow Grass,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0354.htm
		{Yellowknife,Territoires du Nord-Ouest,Canada} /Meteo/Villes/can/Pages/CANT0032.htm
		Yorkton,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0355.htm
		York,Ontario,Canada /Meteo/Villes/can/Pages/CAON0771.htm
		Youbou,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0337.htm
		{Young's Cove Road,Nouveau-Brunswick,Canada} /Meteo/Villes/can/Pages/CANB0110.htm
		Youngstown,Alberta,Canada /Meteo/Villes/can/Pages/CAAB0342.htm
		Young,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0356.htm
		Zealandia,Saskatchewan,Canada /Meteo/Villes/can/Pages/CASK0357.htm
		Zeballos,Colombie-Britannique,Canada /Meteo/Villes/can/Pages/CABC0338.htm
		{Zenon Park,Saskatchewan,Canada} /Meteo/Villes/can/Pages/CASK0358.htm
		Zurich,Ontario,Canada /Meteo/Villes/can/Pages/CAON0772.htm
		Sal,,Cap-Vert /Meteo/Villes/intl/Pages/CVXX0001.htm
		Arica,,Chili /Meteo/Villes/intl/Pages/CIXX0002.htm
		{Puerto Montt,,Chili} /Meteo/Villes/intl/Pages/CIXX0015.htm
		{Punta Arenas,,Chili} /Meteo/Villes/intl/Pages/CIXX0017.htm
		Santiago,,Chili /Meteo/Villes/intl/Pages/CIXX0020.htm
		Beijing,,Chine /Meteo/Villes/intl/Pages/CHXX0008.htm
		{Canton (Guangzhou),,Chine} /Meteo/Villes/intl/Pages/CNXX0004.htm
		Changchun,,Chine /Meteo/Villes/intl/Pages/CHXX0010.htm
		Changsha,,Chine /Meteo/Villes/intl/Pages/CHXX0013.htm
		Chongqing,,Chine /Meteo/Villes/intl/Pages/CNXX0005.htm
		Dalian,,Chine /Meteo/Villes/intl/Pages/CHXX0019.htm
		Fushun,,Chine /Meteo/Villes/intl/Pages/CHXX0029.htm
		Guiyang,,Chine /Meteo/Villes/intl/Pages/CHXX0039.htm
		Hangzhou,,Chine /Meteo/Villes/intl/Pages/CHXX0044.htm
		Harbin,,Chine /Meteo/Villes/intl/Pages/CHXX0046.htm
		{Hong Kong,,Chine} /Meteo/Villes/intl/Pages/HKXX0001.htm
		Kunming,,Chine /Meteo/Villes/intl/Pages/CHXX0076.htm
		Lanzhou,,Chine /Meteo/Villes/intl/Pages/CHXX0079.htm
		{Lhasa (Tibet),,Chine} /Meteo/Villes/intl/Pages/CNXX0006.htm
		Nanjing,,Chine /Meteo/Villes/intl/Pages/CHXX0099.htm
		{Qingdao ,,Chine} /Meteo/Villes/intl/Pages/CHXX0110.htm
		Shanghai,,Chine /Meteo/Villes/intl/Pages/CHXX0116.htm
		Shenyang,,Chine /Meteo/Villes/intl/Pages/CHXX0119.htm
		Taiyuan,,Chine /Meteo/Villes/intl/Pages/CHXX0129.htm
		Tianjin,,Chine /Meteo/Villes/intl/Pages/CHXX0133.htm
		Victoria,,Chine /Meteo/Villes/intl/Pages/CNXX0002.htm
		Wuhan,,Chine /Meteo/Villes/intl/Pages/CHXX0138.htm
		Wuxi,,Chine /Meteo/Villes/intl/Pages/CNXX0001.htm
		Nicosie,,Chypre /Meteo/Villes/intl/Pages/CYXX0005.htm
		Barranquilla,,Colombie /Meteo/Villes/intl/Pages/COXX0001.htm
		Bogotá,,Colombie /Meteo/Villes/intl/Pages/COXX0004.htm
		Cali,,Colombie /Meteo/Villes/intl/Pages/COXX0008.htm
		Cartagena,,Colombie /Meteo/Villes/intl/Pages/COXX0009.htm
		{San Andres,,Colombie} /Meteo/Villes/intl/Pages/COXX0002.htm
		Moroni/Hahaya,,Comores /Meteo/Villes/intl/Pages/CNXX0003.htm
		Brazzaville,,Congo /Meteo/Villes/intl/Pages/CFXX0001.htm
		Kinshasa,,Congo /Meteo/Villes/intl/Pages/CGXX0018.htm
		{Pyongyang,,Corée du Nord} /Meteo/Villes/intl/Pages/KPXX0002.htm
		{Séoul,,Corée du Sud} /Meteo/Villes/intl/Pages/KPXX0001.htm
		{Guanacaste,,Costa Rica} /Meteo/Villes/intl/Pages/CRXX0001.htm
		{Liberia,,Costa Rica} /Meteo/Villes/intl/Pages/CSXX0005.htm
		{Puntarenas,,Costa Rica} /Meteo/Villes/intl/Pages/CSXX0007.htm
		{San Jose,,Costa Rica} /Meteo/Villes/intl/Pages/CSXX0009.htm
		{Abidjan,,Côte d'Ivoire} /Meteo/Villes/intl/Pages/IVXX0001.htm
		Dubrovnik,,Croatie /Meteo/Villes/intl/Pages/HRXX0002.htm
		Rijeka,,Croatie /Meteo/Villes/intl/Pages/HRXX0001.htm
		Split,,Croatie /Meteo/Villes/intl/Pages/HRXX0004.htm
		Zagreb,,Croatie /Meteo/Villes/intl/Pages/HRXX0005.htm
		Bayamo,,Cuba /Meteo/Villes/intl/Pages/CUXX0007.htm
		Camaguey,,Cuba /Meteo/Villes/intl/Pages/CUXX0002.htm
		Cayo-Coco,,Cuba /Meteo/Villes/intl/Pages/CUXX0019.htm
		Cayo-Largo,,Cuba /Meteo/Villes/intl/Pages/CUXX0020.htm
		{Ciego de Avila,,Cuba} /Meteo/Villes/intl/Pages/CUXX0001.htm
		Cienfuegos,,Cuba /Meteo/Villes/intl/Pages/CUXX0017.htm
		Guantanamo,,Cuba /Meteo/Villes/intl/Pages/CUXX0006.htm
		Guardalavaca,,Cuba /Meteo/Villes/intl/Pages/CUXX0004.htm
		Holguín,,Cuba /Meteo/Villes/intl/Pages/CUXX0011.htm
		{La Havane,,Cuba} /Meteo/Villes/intl/Pages/CUXX0003.htm
		{Las Tunas,,Cuba} /Meteo/Villes/intl/Pages/CUXX0012.htm
		Manzanillo,,Cuba /Meteo/Villes/intl/Pages/CUXX0005.htm
		Matanzas,,Cuba /Meteo/Villes/intl/Pages/CUXX0013.htm
		{Pinar del Rio,,Cuba} /Meteo/Villes/intl/Pages/CUXX0008.htm
		{Santa Clara,,Cuba} /Meteo/Villes/intl/Pages/CUXX0009.htm
		{Santiago de Cuba,,Cuba} /Meteo/Villes/intl/Pages/CUXX0010.htm
		Varadero,,Cuba /Meteo/Villes/intl/Pages/CUXX0018.htm
		Copenhague,,Danemark /Meteo/Villes/intl/Pages/DAXX0009.htm
		Djbouti,,Djibouti /Meteo/Villes/intl/Pages/DJXX0001.htm
		Roseau,,Dominique /Meteo/Villes/intl/Pages/DOXX0002.htm
		Alexandria,,Égypte /Meteo/Villes/intl/Pages/EGXX0001.htm
		{Le Caire,,Égypte} /Meteo/Villes/intl/Pages/EGXX0004.htm
		{San Salvador,,El Salvador} /Meteo/Villes/intl/Pages/ESXX0001.htm
		{Abou Dhabi,,Émirats Arabes Unis} /Meteo/Villes/intl/Pages/TCXX0001.htm
		{Dubai,,Émirats Arabes Unis} /Meteo/Villes/intl/Pages/TCXX0004.htm
		Guayaquil,,Équateur /Meteo/Villes/intl/Pages/ECXX0003.htm
		Quito,,Équateur /Meteo/Villes/intl/Pages/ECXX0008.htm
		Barcelone,,Espagne /Meteo/Villes/intl/Pages/ESCT0001.htm
		Bilbao,,Espagne /Meteo/Villes/intl/Pages/ESXX0006.htm
		Cordoue,,Espagne /Meteo/Villes/intl/Pages/ESXX0007.htm
		Ibiza,,Espagne /Meteo/Villes/intl/Pages/SPXX0044.htm
		Madrid,,Espagne /Meteo/Villes/intl/Pages/ESMX0001.htm
		Malaga,,Espagne /Meteo/Villes/intl/Pages/ESAN0001.htm
		{Palma de Mallorca ,,Espagne} /Meteo/Villes/intl/Pages/ESXX0002.htm
		Saragosse,,Espagne /Meteo/Villes/intl/Pages/ESXX0005.htm
		Seville,,Espagne /Meteo/Villes/intl/Pages/ESXX0004.htm
		Valence,,Espagne /Meteo/Villes/intl/Pages/ESXX0003.htm
		Tallinn,,Estonie /Meteo/Villes/intl/Pages/ENXX0004.htm
		ASHTABULA,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0035.htm
		{Aberdeen,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0001.htm
		Aberdeen,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0001.htm
		Abilene,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0002.htm
		Abilene,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0003.htm
		Adams,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0005.htm
		Afton,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0005.htm
		{Aiken,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0003.htm
		Akron,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0008.htm
		Alamogordo,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0003.htm
		Albany,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0009.htm
		{Albany,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0011.htm
		{Albert Lea,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0011.htm
		Albion,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0003.htm
		Albuquerque,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0004.htm
		Alexandria,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0008.htm
		Alexandria,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0017.htm
		Alexandria,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0007.htm
		Allentown,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0025.htm
		Almelund,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0018.htm
		{Alpine Meadows,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0018.htm
		Altoona,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0031.htm
		Alto,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0008.htm
		{Amagansett,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0031.htm
		Amalia,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0009.htm
		Amarillo,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0029.htm
		Ames,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0026.htm
		Anaheim,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0027.htm
		Anatone,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0012.htm
		Anchorage,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0012.htm
		{Andover,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0006.htm
		{Angel Fire,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0011.htm
		{Angels Camp,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0029.htm
		{Ann Arbor,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0028.htm
		Annapolis,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0010.htm
		Anniston,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0023.htm
		Appleton,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0020.htm
		Arapahoe,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0011.htm
		Arcata,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0041.htm
		Ardmore,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0026.htm
		Arlington,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0045.htm
		Arlington,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0023.htm
		{Arroyo Grande,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0045.htm
		Ascutney,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0005.htm
		{Asheville,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0022.htm
		Ashland,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0015.htm
		Ashland,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0031.htm
		Aspen,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0016.htm
		Astoria,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0017.htm
		Atascadero,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0049.htm
		Athens,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0027.htm
		Atlanta,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0028.htm
		{Atlantic City,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0015.htm
		{Au Sable Forks,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0066.htm
		Augusta,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0032.htm
		Augusta,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0013.htm
		Aurora,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0019.htm
		Austin,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0004.htm
		Austin,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0057.htm
		Avon,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0021.htm
		Baggs,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0011.htm
		Bakersfield,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0062.htm
		Baker,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0005.htm
		Baltimore,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0018.htm
		Bandon,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0023.htm
		Bangor,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0017.htm
		{Banner Elk,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0038.htm
		Barre,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0010.htm
		{Barrington,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0004.htm
		Barrow,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0025.htm
		Barstow,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0069.htm
		Bartlesville,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0036.htm
		Bartlett,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0074.htm
		{Bartlett,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0015.htm
		Bastrop,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0031.htm
		{Baton Rouge,Louisiane,États-Unis} /Meteo/Villes/usa/Pages/USLA0033.htm
		{Battle Mountain,Nevada,États-Unis} /Meteo/Villes/usa/Pages/USNV0006.htm
		Bayfield,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0052.htm
		Baytown,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0087.htm
		{Beach Haven,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0030.htm
		Beatrice,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0040.htm
		{Beaufort,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0016.htm
		Beaumont,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0089.htm
		Beckley,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0049.htm
		Bellaire,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0069.htm
		Bellevue,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0018.htm
		Bellevue,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0047.htm
		Bellevue,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0027.htm
		Bellingham,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0028.htm
		Beloit,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0060.htm
		Bemidji,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0064.htm
		Bend,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0031.htm
		{Bennington,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0019.htm
		Bennington,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0017.htm
		Bentonville,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0047.htm
		Berkeley,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0087.htm
		{Berlin,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0020.htm
		Bernville,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0118.htm
		Bethel,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0028.htm
		Bethel,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0030.htm
		{Beverly Hills,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0090.htm
		{Big Bear Lake,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0094.htm
		{Big Horn,Wyoming,États-Unis} /Meteo/Villes/usa/Pages/USWY0017.htm
		{Big Sky,Montana,États-Unis} /Meteo/Villes/usa/Pages/USMT0026.htm
		{Big Sur,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0099.htm
		Billings,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0031.htm
		Biloxi,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0033.htm
		{Binghamton,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0124.htm
		Birmingham,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0054.htm
		Bisbee,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0016.htm
		{Bismarck,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0037.htm
		Biwabik,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0077.htm
		Blakeslee,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0139.htm
		Blanchard,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0021.htm
		Blandford,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0043.htm
		Bloomington,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0113.htm
		Bloomington,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0046.htm
		{Blue Canyon,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0107.htm
		{Blue Mounds,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0077.htm
		Bluefield,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0082.htm
		Blythe,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0110.htm
		{Boca Raton,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0040.htm
		{Bodega Bay,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0112.htm
		Bodines,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0154.htm
		{Boise City,Oklahoma,États-Unis} /Meteo/Villes/usa/Pages/USOK0055.htm
		Boise,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0025.htm
		{Bolton Valley,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0020.htm
		Bondville,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0022.htm
		Boone,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0091.htm
		Boston,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0046.htm
		Boulder,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0038.htm
		{Bowling Green,Kentucky,États-Unis} /Meteo/Villes/usa/Pages/USKY0721.htm
		{Boyne Falls,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0096.htm
		Bozeman,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0040.htm
		Bradenton,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0048.htm
		Bradley,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0123.htm
		Bradley,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0275.htm
		Brainerd,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0091.htm
		Branson,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0099.htm
		Breckenridge,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0040.htm
		{Bretton Woods,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0259.htm
		{Bridgehampton,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0163.htm
		Bridgeport,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0019.htm
		Bridgton,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0047.htm
		Brighton,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0108.htm
		Brinnon,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0044.htm
		Bristol,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0055.htm
		Brockton,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0056.htm
		Brookfield,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0057.htm
		{Brookings,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0041.htm
		Brookings,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0044.htm
		Brownsville,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0166.htm
		Brownsville,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0032.htm
		Brunswick,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0078.htm
		Brutus,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0116.htm
		{Buffalo,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0181.htm
		Buffalo,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0023.htm
		{Bullhead City,Arizona,États-Unis} /Meteo/Villes/usa/Pages/USAZ0023.htm
		Burlington,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0048.htm
		Burlington,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0114.htm
		Burlington,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0033.htm
		Burnsville,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0112.htm
		Butler,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0141.htm
		{Butternut Basin,Massachusetts,États-Unis} /Meteo/Villes/usa/Pages/USMA0063.htm
		Butte,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0052.htm
		Cable,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0108.htm
		Cadillac,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0127.htm
		{Caldwell,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0071.htm
		Calpella,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0158.htm
		Cambridge,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0066.htm
		{Cambridge,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0199.htm
		Camden,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0065.htm
		{Camden,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0073.htm
		{Cannon Beach,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0053.htm
		Cannonsburg,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0131.htm
		Canton,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0156.htm
		{Cape Canaveral,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0066.htm
		{Cape Cod,Massachusetts,États-Unis} /Meteo/Villes/usa/Pages/USMA0068.htm
		{Cape Coral,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0067.htm
		{Cape Girardeau,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0144.htm
		{Cape May,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0074.htm
		Carbondale,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0056.htm
		Carbondale,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0185.htm
		Carlsbad,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0182.htm
		Carmel,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0183.htm
		{Caroga Lake,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0219.htm
		Carpinteria,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0187.htm
		{Carson City,Nevada,États-Unis} /Meteo/Villes/usa/Pages/USNV0014.htm
		{Casa Grande,Arizona,États-Unis} /Meteo/Villes/usa/Pages/USAZ0028.htm
		Casper,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0030.htm
		Caspian,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0145.htm
		Catalina,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0030.htm
		{Cedar City,Utah,États-Unis} /Meteo/Villes/usa/Pages/USUT0038.htm
		{Cedar Rapids,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0138.htm
		Centennial,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0031.htm
		Chadron,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0098.htm
		Champaign,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0209.htm
		{Chapel Hill,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0120.htm
		{Charleston,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0051.htm
		Charleston,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0138.htm
		{Charlotte,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0121.htm
		Chattanooga,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0084.htm
		Chelsea,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0166.htm
		{Cherry Creek,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0261.htm
		Chesterfield,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0170.htm
		Chesterland,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0181.htm
		Cheyenne,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0032.htm
		Chicago,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0225.htm
		Chico,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0688.htm
		{China Lake,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0213.htm
		Choteau,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0063.htm
		Cincinnati,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0188.htm
		Circleville,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0044.htm
		{Citrus Heights,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0221.htm
		Clarksburg,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0146.htm
		Clarkston,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0171.htm
		Clarksville,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0093.htm
		Claymont,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0007.htm
		Clearwater,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0084.htm
		Cleveland,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0195.htm
		Cloverdale,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0232.htm
		Clovis,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0233.htm
		{Clymer,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0297.htm
		Cobalt,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0046.htm
		Cody,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0035.htm
		{Coeur d'Alène,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0279.htm
		Colburn,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0049.htm
		{Colebrook,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0044.htm
		{Colorado Springs,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0078.htm
		{Columbia,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0065.htm
		Columbia,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0103.htm
		Columbia,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0193.htm
		Columbus,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0132.htm
		Columbus,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0126.htm
		Columbus,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0077.htm
		Columbus,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0112.htm
		Columbus,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0212.htm
		Concord,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0247.htm
		{Concord,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0045.htm
		Conway,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0124.htm
		{Cooperstown,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0326.htm
		{Coos Bay,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0072.htm
		Cordova,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0061.htm
		Corinth,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0081.htm
		{Corpus Christi,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX0294.htm
		Cortez,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0086.htm
		{Cortland,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0340.htm
		Corvallis,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0076.htm
		Coudersport,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0339.htm
		{Council Bluffs,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0192.htm
		Covington,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY0801.htm
		{Cranston,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0014.htm
		Creede,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0092.htm
		{Crescent City,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0264.htm
		{Crescent Lake,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0085.htm
		Crescent,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0195.htm
		{Crested Butte,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0093.htm
		Cumberland,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0115.htm
		Curlew,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0103.htm
		Daggett,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0277.htm
		Dallas,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0327.htm
		Dalton,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0158.htm
		Danbury,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0046.htm
		{Danbury,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0050.htm
		Danville,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0206.htm
		Davenport,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0211.htm
		{Davis City,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0212.htm
		{Daytona Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0106.htm
		Dayton,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0245.htm
		Dayton,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0041.htm
		{De Lancey,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0369.htm
		Decatur,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0302.htm
		Deford,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0227.htm
		Dellwood,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0184.htm
		{Delray Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0112.htm
		Denver,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0105.htm
		{Des Moines,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0231.htm
		{Detroit Lakes,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0200.htm
		Detroit,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0229.htm
		Devault,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0400.htm
		{Devil's Lake,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0088.htm
		{Dickinson,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0090.htm
		Dillon,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0106.htm
		{Dodge City,Kansas,États-Unis} /Meteo/Villes/usa/Pages/USKS0152.htm
		Dorena,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0103.htm
		Dothan,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0162.htm
		Douglas,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0058.htm
		Dover,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0012.htm
		{Dover,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0054.htm
		Dresser,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0195.htm
		Driggs,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0066.htm
		{Du Bois,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA0430.htm
		Dublique,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0248.htm
		Duluth,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0208.htm
		Dundalk,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0132.htm
		Dunedin,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0119.htm
		{Dunkirk,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0400.htm
		Durango,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0254.htm
		{Durham,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0192.htm
		Dyersburg,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0154.htm
		{East Burke,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0062.htm
		{East Hampton,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0418.htm
		{East Haven,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0070.htm
		{East Saint Louis,Illinois,États-Unis} /Meteo/Villes/usa/Pages/USIL0345.htm
		{Eau Claire,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0204.htm
		Eden,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0067.htm
		Egnar,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0122.htm
		{El Dorado,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0170.htm
		{El Paso,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX0413.htm
		{El Portal,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0340.htm
		{Elizabeth,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0134.htm
		{Elk City,Oklahoma,États-Unis} /Meteo/Villes/usa/Pages/USOK0175.htm
		Elkhart,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0182.htm
		Elkhorn,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0219.htm
		Elko,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0024.htm
		Ellensburg,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0130.htm
		{Ellicottville,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0458.htm
		{Elmira,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0463.htm
		Ely,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0025.htm
		Empire,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0127.htm
		Emporia,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0178.htm
		Enid,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0178.htm
		Enon,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0296.htm
		Erie,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0509.htm
		Escanaba,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0274.htm
		Escondido,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0356.htm
		Estherville,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0284.htm
		Etters,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0513.htm
		Eugene,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0118.htm
		Eureka,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0360.htm
		Eureka,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0282.htm
		Evanston,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0054.htm
		Evansville,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0190.htm
		{Fabius,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0475.htm
		Fairbanks,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0083.htm
		Fairfield,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0364.htm
		Fairmont,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0250.htm
		{Fargo,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0115.htm
		Fayetteville,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0189.htm
		{Fayetteville,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0234.htm
		{Fayetteville,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0488.htm
		Findlay,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0311.htm
		Flagstaff,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0068.htm
		{Flat Top,Virginie-occidentale,États-Unis} /Meteo/Villes/usa/Pages/USWV0249.htm
		Flint,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0295.htm
		{Florence,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0113.htm
		Florence,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY0121.htm
		Florence,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0123.htm
		{Fond du Lac,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0244.htm
		Forks,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0149.htm
		{Fort Bragg,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0394.htm
		{Fort Collins,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0140.htm
		{Fort Dodge,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0307.htm
		{Fort Garland,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0141.htm
		{Fort Lauderdale,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0149.htm
		{Fort Myers,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0152.htm
		{Fort Pierce,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0156.htm
		{Fort Smith,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0197.htm
		{Fort Stockton,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX0473.htm
		{Fort Walton Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0157.htm
		{Fort Wayne,Indiana,États-Unis} /Meteo/Villes/usa/Pages/USIN0211.htm
		{Fort Worth,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX0474.htm
		{Fortuna ,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0398.htm
		{Franconia,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0077.htm
		Frankfort,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY0919.htm
		Franklin,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0254.htm
		Fraser,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0148.htm
		Fredericksburg,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0294.htm
		Frederick,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0161.htm
		{Freedom,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0079.htm
		Fremont,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0403.htm
		Fremont,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0191.htm
		Fresno,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0406.htm
		Frontenac,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0278.htm
		Gadsden,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0222.htm
		Gainesville,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0163.htm
		Gainesville,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0230.htm
		Galena,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0438.htm
		Gallup,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0121.htm
		Galveston,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0499.htm
		Garberville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0411.htm
		{Garden City,Utah,États-Unis} /Meteo/Villes/usa/Pages/USUT0086.htm
		Gary,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0233.htm
		Gaylord,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0323.htm
		Georgetown,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0020.htm
		Gettysburg,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0604.htm
		Gillette,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0067.htm
		Gilroy,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0420.htm
		Girdwood,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0094.htm
		Glendale,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0083.htm
		Glendale,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0423.htm
		Glendive,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0141.htm
		{Glens Falls,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0568.htm
		Gloucester,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0153.htm
		{Gold Beach,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0142.htm
		Goodland,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0227.htm
		{Goose Prairie,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0166.htm
		Goshen,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0082.htm
		{Grahamsville,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0580.htm
		{Grand Forks,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0146.htm
		{Grand Island,Nebraska,États-Unis} /Meteo/Villes/usa/Pages/USNE0207.htm
		{Grand Junction,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0166.htm
		{Grand Portage,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0308.htm
		{Grand Rapids,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0344.htm
		{Grants Pass,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0146.htm
		Grayling,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0349.htm
		{Great Falls,Montana,États-Unis} /Meteo/Villes/usa/Pages/USMT0146.htm
		{Green Bay,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0288.htm
		{Greensboro,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0280.htm
		{Greenville,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0141.htm
		Greenville,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0141.htm
		{Greenwood Lake,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0599.htm
		Greer,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0092.htm
		Gresham,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0148.htm
		Groton,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0087.htm
		Gulfport,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0145.htm
		Hagerstown,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0195.htm
		{Hampton Bays,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0620.htm
		Hancock,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0104.htm
		Hanford,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0461.htm
		{Harpers Ferry,Virginie-occidentale,États-Unis} /Meteo/Villes/usa/Pages/USWV0326.htm
		Harrisburg,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0679.htm
		Harrisonburg,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0351.htm
		Harrison,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0372.htm
		Hartford,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0094.htm
		Hastings,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0226.htm
		Hattiesburg,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0152.htm
		Hawthorne,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0039.htm
		Hayward,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0470.htm
		Hazleton,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0698.htm
		Healdsburg,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0471.htm
		Hebo,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0155.htm
		Helena,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0163.htm
		Hemet,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0476.htm
		Henderson,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0040.htm
		{Henniker,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0106.htm
		Hesperia,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0481.htm
		Hesperus,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0186.htm
		Hialeah,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0196.htm
		Hibbing,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0349.htm
		{Hickory,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0312.htm
		{Hidden Valley,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA0714.htm
		{Highmount,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0659.htm
		{Hill City,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0350.htm
		{Hillsdale,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0661.htm
		Hilo,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0022.htm
		Hobbs,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0141.htm
		Hollywood,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0204.htm
		Holly,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0397.htm
		{Holmes City,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0362.htm
		Holyoke,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0186.htm
		Homer,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0105.htm
		Homestead,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0208.htm
		Homewood,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0491.htm
		Honolulu,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0026.htm
		Hope,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0273.htm
		Hopkinsville,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY1010.htm
		Hopkins,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0403.htm
		Hopland,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0495.htm
		Hoquiam,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0188.htm
		{Horseshoe Bend,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0116.htm
		{Hot Springs,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0276.htm
		{Hot Springs,Virginie,États-Unis} /Meteo/Villes/usa/Pages/USVA0373.htm
		{Houghton Lake,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0406.htm
		Houlton,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0185.htm
		Houma,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0224.htm
		Houston,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0617.htm
		Hughesville,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0745.htm
		Humptulips,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0189.htm
		{Hunter,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0699.htm
		{Huntington Beach,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0500.htm
		Huntington,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0358.htm
		Huntsville,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0287.htm
		Hutchinson,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0283.htm
		{Idaho Falls,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0120.htm
		Ilwaco,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0192.htm
		Imperial,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0508.htm
		{Incline Village,Nevada,États-Unis} /Meteo/Villes/usa/Pages/USNV0043.htm
		Independence,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0441.htm
		Indianapolis,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0305.htm
		{International Falls,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0376.htm
		{Iowa City,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0414.htm
		Ironwood,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0429.htm
		Islamorada,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0225.htm
		{Island Pond,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0116.htm
		Issaquah,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0197.htm
		{Jacksonville,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0342.htm
		Jacksonville,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0228.htm
		Jackson,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0175.htm
		{Jackson,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0115.htm
		Jackson,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0255.htm
		{Jamestown,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0179.htm
		Janesville,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0346.htm
		{Jay Peak,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0120.htm
		{Jefferson City,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0453.htm
		{Jersey City,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0234.htm
		{Johnson City,Tennessee,États-Unis} /Meteo/Villes/usa/Pages/USTN0261.htm
		Jonesboro,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0304.htm
		Jones,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0440.htm
		Joplin,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0457.htm
		{June Lake,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0532.htm
		Juneau,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0116.htm
		Jupiter,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0237.htm
		Kahului,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0085.htm
		Kailua-Kona,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0095.htm
		Kalamazoo,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0442.htm
		Kalispell,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0188.htm
		{Kansas City,Kansas,États-Unis} /Meteo/Villes/usa/Pages/USKS0298.htm
		{Kansas City,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0460.htm
		{Kearsarge,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0118.htm
		{Keene,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0119.htm
		Kennebunkport,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0201.htm
		Kenner,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0247.htm
		Kennewick,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0205.htm
		Keokuk,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0434.htm
		Ketchikan,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0125.htm
		{Key Largo,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0243.htm
		{Key West,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0244.htm
		{Kiamesha Lake,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0754.htm
		Killington,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0125.htm
		Kimball,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0410.htm
		{King City,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0544.htm
		Kingfield,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0203.htm
		Kingman,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0113.htm
		Kingsport,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0265.htm
		Kingsville,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0697.htm
		Kirksville,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0475.htm
		Kirkwood,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0550.htm
		Kissimmee,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0248.htm
		{Kit Carson,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0552.htm
		{Klamath Falls,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0186.htm
		Klamath,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0553.htm
		Knoxville,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0268.htm
		Kodiak,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0133.htm
		Kokomo,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0331.htm
		{La Canada Flintridge,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0560.htm
		{La Crosse,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0372.htm
		{La Grande,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0187.htm
		{La Nouvelle-Orléans,Louisiane,États-Unis} /Meteo/Villes/usa/Pages/USLA0338.htm
		{La Salle/Peru,Illinois,États-Unis} /Meteo/Villes/usa/Pages/USIL0635.htm
		{Laconia,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0121.htm
		Lafayette,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0340.htm
		Lafayette,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0261.htm
		Lahaina,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0055.htm
		{Lake Charles,Louisiane,États-Unis} /Meteo/Villes/usa/Pages/USLA0265.htm
		{Lake Como,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA0848.htm
		{Lake George,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0338.htm
		{Lake Placid,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0778.htm
		{Lake Tahoe,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0584.htm
		{Lake Toxaway,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0369.htm
		Lakeland,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0267.htm
		Lakeshore,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0587.htm
		Lakeside,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0194.htm
		Lakeside,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0191.htm
		Lakewood,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0229.htm
		Lancaster,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0591.htm
		Lancaster,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0490.htm
		Lancaster,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0857.htm
		Lander,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0101.htm
		Lansing,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0477.htm
		Laramie,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0102.htm
		Laredo,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0737.htm
		{Las Cruces,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0169.htm
		{Las Vegas,Nevada,États-Unis} /Meteo/Villes/usa/Pages/USNV0049.htm
		{Las Vegas,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0170.htm
		Latham,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0493.htm
		Laughlin,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0051.htm
		Lawrenceburg,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0355.htm
		Lawrence,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0319.htm
		Lawton,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0307.htm
		Leadville,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0235.htm
		{Lead,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0190.htm
		Leavenworth,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0321.htm
		{Lebanon,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0123.htm
		Leggett,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0602.htm
		Lewiston,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0146.htm
		Lewiston,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0213.htm
		Lexington,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY1079.htm
		Libby,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0202.htm
		Lihue,Hawaii,États-Unis /Meteo/Villes/usa/Pages/USHI0097.htm
		Lima,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0510.htm
		{Lincoln City,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0197.htm
		Lincoln,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0218.htm
		Lincoln,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0283.htm
		{Lincoln,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0125.htm
		{Little Falls,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0815.htm
		{Little Rock,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0336.htm
		Littleton,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0221.htm
		Lodi,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0623.htm
		Logan,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0147.htm
		Lompoc,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0628.htm
		Londonderry,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0128.htm
		{Long Beach,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0632.htm
		Longview,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0793.htm
		{Los Alamos,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0179.htm
		{Los Angeles,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0638.htm
		{Los Gatos,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0641.htm
		Louisville,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY1096.htm
		Louviers,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0245.htm
		Lowell,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0223.htm
		Loyal,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0404.htm
		Loysburg,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA0941.htm
		Lubbock,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0808.htm
		Ludlow,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0131.htm
		Lutsen,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0458.htm
		{Lyme Center,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0133.htm
		{Lyme,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0132.htm
		Lynchburg,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0453.htm
		Mack,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0249.htm
		Macon,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0346.htm
		Madera,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0657.htm
		Madison,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0411.htm
		{Maggie Valley,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0411.htm
		Malibu,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0660.htm
		{Mammoth Lakes,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0661.htm
		{Manchester Center,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0137.htm
		Manchester,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0110.htm
		{Manchester,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0136.htm
		Manhattan,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0358.htm
		Manitowoc,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0416.htm
		Mankato,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0471.htm
		Mansfield,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0549.htm
		Manteca,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0665.htm
		Marathon,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0300.htm
		Marietta,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0353.htm
		Marinette,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0422.htm
		Marquette,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0525.htm
		{Mars Hill,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0424.htm
		Martubsburg,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0466.htm
		{Marysville Beale AFB,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0677.htm
		Marysville,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0220.htm
		{Mason City,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0541.htm
		{Massena,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0881.htm
		McGaheysville,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0483.htm
		McHenry,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0265.htm
		Mcalester,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0347.htm
		Mccomb,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0224.htm
		Medford,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0215.htm
		Melbourne,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0311.htm
		Melcroft,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1025.htm
		Memphis,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0325.htm
		Mendocino,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0690.htm
		Menominee,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0545.htm
		Merced,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0695.htm
		{Mercer Island,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0271.htm
		Mercersburg,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1030.htm
		Meridian,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0232.htm
		Merrimac,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0447.htm
		{Merritt Island,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0314.htm
		Mesa,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0136.htm
		Metairie,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0314.htm
		Methuen,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0251.htm
		Miami,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0316.htm
		{Michigan City,Indiana,États-Unis} /Meteo/Villes/usa/Pages/USIN0412.htm
		{Middlebury College Snow Bowl,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0310.htm
		Middlefield,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0119.htm
		Middletown,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0035.htm
		Midland,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0888.htm
		{Miles City,Montana,États-Unis} /Meteo/Villes/usa/Pages/USMT0229.htm
		Milford,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0036.htm
		Milford,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0162.htm
		Mills,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0120.htm
		{Millville,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0315.htm
		Milwaukee,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0455.htm
		{Minisink Hills,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1074.htm
		Minneapolis,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0503.htm
		{Minot,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0242.htm
		Mio,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0561.htm
		{Mission Viejo,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0712.htm
		Missoula,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0231.htm
		{Mitchell,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0226.htm
		Moab,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0165.htm
		Mobile,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0371.htm
		Modesto,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0714.htm
		Monarch,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0272.htm
		Monroe,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0319.htm
		{Montauk,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0939.htm
		Monterey,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0724.htm
		Monteview,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0166.htm
		Montezuma,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0583.htm
		Montgomery,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0375.htm
		Montpelier,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0147.htm
		Moorhead,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0514.htm
		Moosic,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1093.htm
		{Morgan Hill,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0731.htm
		Morgantown,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0507.htm
		Morris,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1097.htm
		{Morro Bay,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0733.htm
		{Moses Lake,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0285.htm
		{Mount Baldy,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0737.htm
		{Mount Bethel,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1105.htm
		{Mount Hood Parkdale,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0233.htm
		{Mount Shasta,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0741.htm
		{Mount Washington,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0154.htm
		{Mountain Top,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1118.htm
		Mullan,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0174.htm
		Muncie,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0452.htm
		Murfreesboro,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0356.htm
		Muskogee,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0376.htm
		{Myrtle Beach,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0239.htm
		Nampa,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0178.htm
		Napa,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0750.htm
		Naples,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0338.htm
		{Naples,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0971.htm
		{Nashua,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0156.htm
		Nashville,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0457.htm
		Nashville,Tennessee,États-Unis /Meteo/Villes/usa/Pages/USTN0357.htm
		Natchez,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0255.htm
		Needles,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0753.htm
		Neihart,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0239.htm
		Nellysford,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0536.htm
		Nevada,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0628.htm
		{New Albany,Indiana,États-Unis} /Meteo/Villes/usa/Pages/USIN0460.htm
		{New Bedford,Massachusetts,États-Unis} /Meteo/Villes/usa/Pages/USMA0275.htm
		{New Britain,Connecticut,États-Unis} /Meteo/Villes/usa/Pages/USCT0131.htm
		{New Brunswick,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0348.htm
		{New Haven,Connecticut,États-Unis} /Meteo/Villes/usa/Pages/USCT0135.htm
		{New Iberia,Louisiane,États-Unis} /Meteo/Villes/usa/Pages/USLA0337.htm
		{New London,Connecticut,États-Unis} /Meteo/Villes/usa/Pages/USCT0136.htm
		{New Meadows,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0180.htm
		{New Paltz,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0990.htm
		{New York,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY0996.htm
		Newark,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0043.htm
		{Newark,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0355.htm
		Newark,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0688.htm
		{Newbury,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0163.htm
		{Newfoundland,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0357.htm
		{Newport Beach,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0764.htm
		Newport,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0245.htm
		Niceville,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0344.htm
		Nogales,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0146.htm
		Nome,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0170.htm
		Norden,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0773.htm
		Norfolk,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0557.htm
		Norman,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0388.htm
		{North Bend,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0247.htm
		{North Conway,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0169.htm
		{North Creek,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1028.htm
		{North Little Rock,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0412.htm
		{North Platte,Nebraska,États-Unis} /Meteo/Villes/usa/Pages/USNE0353.htm
		Northland,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0611.htm
		Northstar-At-Tahoe,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0781.htm
		Norway,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0615.htm
		Norwich,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0155.htm
		Novato,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0783.htm
		Oakland,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0791.htm
		Ocala,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0355.htm
		Oceanside,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0797.htm
		Odessa,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0045.htm
		Odessa,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0984.htm
		Ogden,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0187.htm
		Ogunquit,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0293.htm
		Ohiopyle,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1218.htm
		{Oklahoma City,Oklahoma,États-Unis} /Meteo/Villes/usa/Pages/USOK0400.htm
		{Old Orchard Beach,Maine,États-Unis} /Meteo/Villes/usa/Pages/USME0295.htm
		Olympia,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0318.htm
		Omaha,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0363.htm
		Omak,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0320.htm
		Ontario,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0806.htm
		Ophir,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0292.htm
		{Orangeburg,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0256.htm
		Orem,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0191.htm
		Orick,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0812.htm
		{Orkney Springs,Virginie,États-Unis} /Meteo/Villes/usa/Pages/USVA0581.htm
		Orlando,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0372.htm
		{Ormond Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0374.htm
		Oroville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0691.htm
		Osburn,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0191.htm
		Oshkosh,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0524.htm
		Otsego,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0642.htm
		{Otto,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0509.htm
		{Overland Park,Kansas,États-Unis} /Meteo/Villes/usa/Pages/USKS0450.htm
		Owensboro,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY1212.htm
		Oxford,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0242.htm
		Oxford,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0275.htm
		Oxnard,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0819.htm
		{Pacific Grove,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0820.htm
		Packwood,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0333.htm
		{Padre Island,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX1008.htm
		Paducah,Kentucky,États-Unis /Meteo/Villes/usa/Pages/USKY1215.htm
		{Palm Springs,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0828.htm
		Palmdale,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0829.htm
		{Palo Alto,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0830.htm
		{Panama City,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0392.htm
		Paradise,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0689.htm
		{Park City,Utah,États-Unis} /Meteo/Villes/usa/Pages/USUT0195.htm
		Parkersburg,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0572.htm
		Pasadena,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0840.htm
		Pasadena,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX1024.htm
		Pascagoula,Mississippi,États-Unis /Meteo/Villes/usa/Pages/USMS0281.htm
		{Paso Robles,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0842.htm
		{Paterson,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0393.htm
		{Pawtucket,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0047.htm
		{Pearl City,Hawaii,États-Unis} /Meteo/Villes/usa/Pages/USHI0078.htm
		Pecos,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX1033.htm
		Pendleton,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0267.htm
		Peninsula,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0758.htm
		Pensacola,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0400.htm
		Peoria,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL0935.htm
		Peru,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0183.htm
		Petaluma,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0854.htm
		Philadelphie,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1276.htm
		Philipsburg,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0256.htm
		{Phillipsburg,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0405.htm
		Phillips,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0541.htm
		Phoenix,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0166.htm
		{Pierre,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0269.htm
		{Pigeon Forge,Tennessee,États-Unis} /Meteo/Villes/usa/Pages/USTN0398.htm
		{Pine Bluff,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0452.htm
		Pinecrest,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0866.htm
		Pinedale,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0134.htm
		Pittsburgh,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1290.htm
		Pittsfield,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0330.htm
		{Plattekill,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1142.htm
		{Plattsburgh,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1143.htm
		{Plymouth,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0190.htm
		Plymouth,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0188.htm
		Pocatello,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0204.htm
		{Point Arena,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0884.htm
		{Point Mugu,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0885.htm
		Polaris,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0261.htm
		Pomona,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0889.htm
		{Pompano Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0412.htm
		{Poplar Bluff,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0713.htm
		{Port Angeles,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0346.htm
		{Port Arthur,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX1073.htm
		{Port Charlotte,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0415.htm
		{Port Huron,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0684.htm
		{Port Orford,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0274.htm
		{Port St. Lucie,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0419.htm
		Portage,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0559.htm
		Porterville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0894.htm
		Portland,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0328.htm
		Portland,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0275.htm
		{Portsmouth,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0191.htm
		Powderhorn,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0321.htm
		Prescott,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0178.htm
		{Presque Isle,Maine,États-Unis} /Meteo/Villes/usa/Pages/USME0330.htm
		Pricedale,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1329.htm
		{Princeton,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0427.htm
		{Providence,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0050.htm
		Provo,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0208.htm
		Quechee,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0195.htm
		Queen,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1340.htm
		Quinault,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0360.htm
		{Quogue,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1194.htm
		Racine,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0575.htm
		{Raleigh,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0558.htm
		{Ramsey,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0432.htm
		{Rancho Santa Margarita,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0915.htm
		{Rapid City,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0283.htm
		Rawlins,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0140.htm
		Raymond,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0365.htm
		Reading,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1348.htm
		{Red Bluff,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0919.htm
		{Red Lodge,Montana,États-Unis} /Meteo/Villes/usa/Pages/USMT0278.htm
		{Red River,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0255.htm
		Redding,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0922.htm
		{Redfield,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1205.htm
		Reeders,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1355.htm
		Reedsport,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0285.htm
		Reno,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0076.htm
		Rhododendron,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0287.htm
		{Rice Lake,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0588.htm
		Richfield,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0213.htm
		Richmond,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0936.htm
		Richmond,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0560.htm
		Richmond,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0652.htm
		{Rio Dell,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0940.htm
		{Riverside/March AFB,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0950.htm
		Riverside,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0949.htm
		Riverton,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0143.htm
		Roanoke,Virginie,États-Unis /Meteo/Villes/usa/Pages/USVA0659.htm
		Rochester,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0632.htm
		{Rochester,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0194.htm
		{Rochester,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1232.htm
		{Rock Cave,Virginie-occidentale,États-Unis} /Meteo/Villes/usa/Pages/USWV0649.htm
		{Rock Hill,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0292.htm
		{Rock Springs,Wyoming,États-Unis} /Meteo/Villes/usa/Pages/USWY0146.htm
		{Rockaway Beach,Oregon,États-Unis} /Meteo/Villes/usa/Pages/USOR0294.htm
		Rockford,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL1013.htm
		Rockford,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0722.htm
		{Rocky Mount,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0581.htm
		Rolla,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0768.htm
		Rollinsville,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0339.htm
		Rome,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0488.htm
		Roswell,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0491.htm
		Roswell,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0267.htm
		Roxbury,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0191.htm
		{Running Springs,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0964.htm
		Rutland,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0205.htm
		Sacramento,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0967.htm
		{Sag Harbor,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1268.htm
		{Sagaponack,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1269.htm
		Saginaw,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0739.htm
		{Saint Albans,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0207.htm
		{Saint Charles,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0782.htm
		{Saint Cloud,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0657.htm
		{Saint George,Utah,États-Unis} /Meteo/Villes/usa/Pages/USUT0222.htm
		{Saint Johnsbury,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0208.htm
		{Saint Joseph,Missouri,États-Unis} /Meteo/Villes/usa/Pages/USMO0786.htm
		{Saint Paul,Minnesota,États-Unis} /Meteo/Villes/usa/Pages/USMN0665.htm
		{Saint Petersburg,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0438.htm
		Saint-Louis,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0964.htm
		Salem,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0591.htm
		Salem,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0360.htm
		Salem,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0304.htm
		Salinas,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA0971.htm
		Salisbury,Maryland,États-Unis /Meteo/Villes/usa/Pages/USMD0358.htm
		{Salt Lake City,Utah,États-Unis} /Meteo/Villes/usa/Pages/USUT0225.htm
		{San Antonio,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX1200.htm
		{San Bernardino,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0978.htm
		{San Clemente,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0981.htm
		{San Cristobal,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0277.htm
		{San Diego,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0982.htm
		{San Francisco,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0987.htm
		{San Jose,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0993.htm
		{San Lucas,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA0999.htm
		{San Luis Obispo,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1000.htm
		{San Mateo,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1005.htm
		{San Nicolas Island,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1007.htm
		{San Rafael,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1011.htm
		{San Simeon,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1013.htm
		{Sandia Park,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0286.htm
		Sandpoint,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0230.htm
		Sandusky,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0855.htm
		Sandy,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0226.htm
		Sanford,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0443.htm
		{Santa Ana,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1016.htm
		{Santa Barbara,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1017.htm
		{Santa Clara,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1019.htm
		{Santa Clarita,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1018.htm
		{Santa Cruz,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1020.htm
		{Santa Fe,Nouveau-Mexique,États-Unis} /Meteo/Villes/usa/Pages/USNM0292.htm
		{Santa Maria,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1023.htm
		{Santa Monica,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1024.htm
		{Santa Paula,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1025.htm
		{Santa Rosa,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1027.htm
		{Saranac Lake,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1286.htm
		Sarasota,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0446.htm
		{Sault Sainte Marie,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0758.htm
		Savannah,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0506.htm
		Saxon,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0620.htm
		Scottsbluff,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0436.htm
		Scottsdale,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0207.htm
		Scranton,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1459.htm
		Seaford,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0050.htm
		Seaside,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0312.htm
		Seattle,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0395.htm
		Sebago,Maine,États-Unis /Meteo/Villes/usa/Pages/USME0364.htm
		{Seeley Lake,Montana,États-Unis} /Meteo/Villes/usa/Pages/USMT0308.htm
		Shattuckville,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0369.htm
		{Shelter Island,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1317.htm
		Shelton,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0403.htm
		Sheridan,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0154.htm
		Shreveport,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0427.htm
		Sidney,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0444.htm
		Sierra-At-Tahoe,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1057.htm
		{Silver Springs,Nevada,États-Unis} /Meteo/Villes/usa/Pages/USNV0083.htm
		{Simi Valley,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1060.htm
		{Sioux City,Iowa,États-Unis} /Meteo/Villes/usa/Pages/USIA0793.htm
		{Sioux Falls,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0315.htm
		Sitka,Alaska,États-Unis /Meteo/Villes/usa/Pages/USAK0224.htm
		Skykomish,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0410.htm
		{Slaty Fork,Virginie-occidentale,États-Unis} /Meteo/Villes/usa/Pages/USWV0697.htm
		Slidell,Louisiane,États-Unis /Meteo/Villes/usa/Pages/USLA0438.htm
		Slidell,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX1269.htm
		Slinger,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0640.htm
		{Smith River,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1065.htm
		{Smuggler's Notch,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0298.htm
		{Snowmass Village,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0363.htm
		{Soda Springs,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1069.htm
		Soledad,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1071.htm
		Sonora,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1077.htm
		{South Bend,Indiana,États-Unis} /Meteo/Villes/usa/Pages/USIN0624.htm
		{South Bend,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0415.htm
		{South Burlington,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0221.htm
		{South Gibson,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1538.htm
		{South Glens Falls,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1364.htm
		{South Lake Tahoe,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1083.htm
		{Southampton,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1377.htm
		Southington,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0213.htm
		Sparks,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0086.htm
		{Spartanburg,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0325.htm
		Spokane,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0422.htm
		{Spring Hill,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0465.htm
		Springdale,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0522.htm
		Springfield,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL1114.htm
		Springfield,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0405.htm
		Springfield,Missouri,États-Unis /Meteo/Villes/usa/Pages/USMO0828.htm
		Springfield,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0908.htm
		{Squaw Valley USA,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1090.htm
		Stamford,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0218.htm
		Stanley,Idaho,États-Unis /Meteo/Villes/usa/Pages/USID0246.htm
		{Steamboat Springs,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0370.htm
		{Stephentown,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1404.htm
		Sterling,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0371.htm
		{Stockholm,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0503.htm
		Stockton,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1100.htm
		Stowe,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0233.htm
		{Stratton Mountain,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0314.htm
		{Sturgis,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0030.htm
		{Suffern,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1422.htm
		Sula,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0324.htm
		{Summit Hill,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1602.htm
		Summit,Utah,États-Unis /Meteo/Villes/usa/Pages/USUT0245.htm
		{Sumter,Caroline du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSC0333.htm
		{Sun City,Arizona,États-Unis} /Meteo/Villes/usa/Pages/USAZ0222.htm
		{Sun Valley,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0251.htm
		Sunnyvale,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1116.htm
		Superior,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0676.htm
		{Swain,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1429.htm
		Sweetgrass,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0329.htm
		{Syracuse,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1434.htm
		Tacoma,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0442.htm
		Tafton,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1617.htm
		{Tahoe City,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1125.htm
		Tallahassee,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0479.htm
		Tampa,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0481.htm
		Taos,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0314.htm
		Tariffville,Connecticut,États-Unis /Meteo/Villes/usa/Pages/USCT0227.htm
		{Taylor Ridge,Illinois,États-Unis} /Meteo/Villes/usa/Pages/USIL1150.htm
		Telluride,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0447.htm
		Tempe,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0233.htm
		{Temple,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0223.htm
		Tererro,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0317.htm
		{Terre Haute,Indiana,États-Unis} /Meteo/Villes/usa/Pages/USIN0660.htm
		Texarkana,Arkansas,États-Unis /Meteo/Villes/usa/Pages/USAR0543.htm
		{Texas City,Texas,États-Unis} /Meteo/Villes/usa/Pages/USTX1348.htm
		Thermal,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1142.htm
		Thompsonville,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0822.htm
		{Thousand Oaks,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1145.htm
		Tillamook,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0347.htm
		Titusville,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0490.htm
		Toledo,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH0953.htm
		Tomah,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0688.htm
		Tonopah,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0091.htm
		Topeka,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0571.htm
		Tracy,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1155.htm
		{Traverse City,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0829.htm
		Trenary,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0830.htm
		{Trenton,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0524.htm
		Trinidad,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0384.htm
		Truckee,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1163.htm
		Tucson,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0247.htm
		Tulare,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1165.htm
		{Tully,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1462.htm
		Tulsa,Oklahoma,États-Unis /Meteo/Villes/usa/Pages/USOK0537.htm
		{Tupper Lake,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1464.htm
		{Turin,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1465.htm
		Turlock,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1169.htm
		Tuscaloosa,Alabama,États-Unis /Meteo/Villes/usa/Pages/USAL0542.htm
		{Twin Bridges,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1174.htm
		{Twin Falls,Idaho,États-Unis} /Meteo/Villes/usa/Pages/USID0263.htm
		Tyler,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX0367.htm
		Ukiah,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1176.htm
		Utica,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0750.htm
		{Utica,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1476.htm
		Vacaville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1181.htm
		Vadito,Nouveau-Mexique,États-Unis /Meteo/Villes/usa/Pages/USNM0337.htm
		{Vail Mountain Resort,Colorado,États-Unis} /Meteo/Villes/usa/Pages/USCO0389.htm
		Vail,Colorado,États-Unis /Meteo/Villes/usa/Pages/USCO0388.htm
		Valdosta,Georgie,États-Unis /Meteo/Villes/usa/Pages/USGA0589.htm
		Valentine,Nebraska,États-Unis /Meteo/Villes/usa/Pages/USNE0494.htm
		Vallejo,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1184.htm
		Valparaiso,Indiana,États-Unis /Meteo/Villes/usa/Pages/USIN0680.htm
		Valyermo,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1189.htm
		Vancouver,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0468.htm
		Venice,Floride,États-Unis /Meteo/Villes/usa/Pages/USFL0497.htm
		Ventura,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1193.htm
		{Vernon,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0531.htm
		Victoria,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX1405.htm
		Victorville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1197.htm
		Vidal,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1198.htm
		{Vineland,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0536.htm
		{Virginia Beach,Virginie,États-Unis} /Meteo/Villes/usa/Pages/USVA0797.htm
		Visalia,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1204.htm
		Waco,Texas,États-Unis /Meteo/Villes/usa/Pages/USTX1413.htm
		{Wainscott,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1502.htm
		Waitsfield,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0251.htm
		Wakefield,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0858.htm
		Waldport,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0366.htm
		{Walhalla,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0361.htm
		{Walla Walla,Washington,États-Unis} /Meteo/Villes/usa/Pages/USWA0476.htm
		Warren,Michigan,États-Unis /Meteo/Villes/usa/Pages/USMI0865.htm
		Warren,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0254.htm
		{Warwick,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0063.htm
		{Washington,District fédéral de Columbia,États-Unis} /Meteo/Villes/usa/Pages/USDC0001.htm
		{Water Mill,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1521.htm
		Waterford,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0719.htm
		Waterloo,Iowa,États-Unis /Meteo/Villes/usa/Pages/USIA0894.htm
		{Watertown,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0365.htm
		{Watertown,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1525.htm
		{Waterville Valley,New Hampshire,États-Unis} /Meteo/Villes/usa/Pages/USNH0232.htm
		Waterville,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0258.htm
		Watsonville,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1215.htm
		Waukesha,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0723.htm
		Wausau,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0727.htm
		Wautoma,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0729.htm
		Welch,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0789.htm
		Wenatchee,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0487.htm
		{West Bend,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0733.htm
		{West Dover,Vermont,États-Unis} /Meteo/Villes/usa/Pages/USVT0265.htm
		{West Hollywood,Californie,États-Unis} /Meteo/Villes/usa/Pages/USCA1225.htm
		{West Memphis,Arkansas,États-Unis} /Meteo/Villes/usa/Pages/USAR0591.htm
		{West Palm Beach,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0512.htm
		{Westernville,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1578.htm
		{Westhampton Beach,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1582.htm
		{Westhampton,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1581.htm
		Westminster,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0479.htm
		Wheeling,Virginie-occidentale,États-Unis /Meteo/Villes/usa/Pages/USWV0799.htm
		{White Haven,Pennsylvanie,États-Unis} /Meteo/Villes/usa/Pages/USPA1785.htm
		{White Lake,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0887.htm
		{White Pine,Michigan,États-Unis} /Meteo/Villes/usa/Pages/USMI0889.htm
		Whitefish,Montana,États-Unis /Meteo/Villes/usa/Pages/USMT0356.htm
		Wichita,Kansas,États-Unis /Meteo/Villes/usa/Pages/USKS0620.htm
		{Wildwood,New Jersey,États-Unis} /Meteo/Villes/usa/Pages/USNJ0564.htm
		Wilkes-Barre,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1796.htm
		Williamsport,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1799.htm
		Williams,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0264.htm
		{Williston,Dakota du Nord,États-Unis} /Meteo/Villes/usa/Pages/USND0372.htm
		Willits,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1242.htm
		{Wilmington,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0760.htm
		Wilmington,Delaware,États-Unis /Meteo/Villes/usa/Pages/USDE0055.htm
		Wilmot,Wisconsin,États-Unis /Meteo/Villes/usa/Pages/USWI0749.htm
		Wilson,Wyoming,États-Unis /Meteo/Villes/usa/Pages/USWY0177.htm
		{Windham,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1608.htm
		Winnemucca,Nevada,États-Unis /Meteo/Villes/usa/Pages/USNV0101.htm
		Winslow,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0268.htm
		{Winston-Salem,Caroline du Nord,États-Unis} /Meteo/Villes/usa/Pages/USNC0767.htm
		{Winter Haven,Floride,États-Unis} /Meteo/Villes/usa/Pages/USFL0524.htm
		{Wisconsin Dells,Wisconsin,États-Unis} /Meteo/Villes/usa/Pages/USWI0756.htm
		Woodland,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1261.htm
		Woodridge,Illinois,États-Unis /Meteo/Villes/usa/Pages/USIL1288.htm
		Woodstock,Vermont,États-Unis /Meteo/Villes/usa/Pages/USVT0295.htm
		{Woonsocket,Rhode Island,États-Unis} /Meteo/Villes/usa/Pages/USRI0069.htm
		Worcester,Massachusetts,États-Unis /Meteo/Villes/usa/Pages/USMA0502.htm
		Wothington,Minnesota,États-Unis /Meteo/Villes/usa/Pages/USMN0816.htm
		Woxall,Pennsylvanie,États-Unis /Meteo/Villes/usa/Pages/USPA1823.htm
		Wrightwood,Californie,États-Unis /Meteo/Villes/usa/Pages/USCA1263.htm
		Yachats,Oregon,États-Unis /Meteo/Villes/usa/Pages/USOR0392.htm
		Yakima,Washington,États-Unis /Meteo/Villes/usa/Pages/USWA0502.htm
		{Yankton,Dakota du Sud,États-Unis} /Meteo/Villes/usa/Pages/USSD0392.htm
		{Yonkers,New York,États-Unis} /Meteo/Villes/usa/Pages/USNY1629.htm
		Youngstown,Ohio,États-Unis /Meteo/Villes/usa/Pages/USOH1075.htm
		Yuma,Arizona,États-Unis /Meteo/Villes/usa/Pages/USAZ0275.htm
		{Addis Ababa,,Éthiopie} /Meteo/Villes/intl/Pages/ETXX0001.htm
		Nadi,,Fidji /Meteo/Villes/intl/Pages/FJXX0001.htm
		Nausori,,Fidji /Meteo/Villes/intl/Pages/FJXX0005.htm
		Suva,,Fidji /Meteo/Villes/intl/Pages/FJXX0009.htm
		Helsinki,,Finlande /Meteo/Villes/intl/Pages/FIXX0002.htm
		Avignon,,France /Meteo/Villes/intl/Pages/FRXX0001.htm
		Belfort,,France /Meteo/Villes/intl/Pages/FRXX0012.htm
		Bordeaux,,France /Meteo/Villes/intl/Pages/FRXX0016.htm
		Cannes,,France /Meteo/Villes/intl/Pages/FRXX0023.htm
		Lille,,France /Meteo/Villes/intl/Pages/FRXX0006.htm
		Lyon,,France /Meteo/Villes/intl/Pages/FRXX0055.htm
		Marseille,,France /Meteo/Villes/intl/Pages/FRXX0059.htm
		Montpellier,,France /Meteo/Villes/intl/Pages/FRXX0002.htm
		Mulhouse,,France /Meteo/Villes/intl/Pages/FRXX0071.htm
		Nantes,,France /Meteo/Villes/intl/Pages/FRXX0072.htm
		Nice,,France /Meteo/Villes/intl/Pages/FRXX0073.htm
		Paris,,France /Meteo/Villes/intl/Pages/FRXX0076.htm
		Reims,,France /Meteo/Villes/intl/Pages/FRXX0005.htm
		Rennes,,France /Meteo/Villes/intl/Pages/FRXX0003.htm
		Strasbourg,,France /Meteo/Villes/intl/Pages/FRXX0095.htm
		Toulouse,,France /Meteo/Villes/intl/Pages/FRXX0099.htm
		Libreville,,Gabon /Meteo/Villes/intl/Pages/GBXX0004.htm
		Banjul,,Gambie /Meteo/Villes/intl/Pages/GAXX0001.htm
		T'Bilisi,,Géorgie /Meteo/Villes/intl/Pages/GGXX0004.htm
		Accra,,Ghana /Meteo/Villes/intl/Pages/GHXX0001.htm
		Athènes,,Grèce /Meteo/Villes/intl/Pages/GRXX0004.htm
		Patras,,Grèce /Meteo/Villes/intl/Pages/GRXX0003.htm
		Thessalonique,,Grèce /Meteo/Villes/intl/Pages/GRXX0002.htm
		Saint-George's,,Grenade /Meteo/Villes/intl/Pages/GDXX0001.htm
		Pointe-à-Pitre,,Guadeloupe /Meteo/Villes/intl/Pages/GPXX0003.htm
		Guatemala,,Guatemala /Meteo/Villes/intl/Pages/GTXX0002.htm
		Conakry,,Guinée /Meteo/Villes/intl/Pages/GVXX0002.htm
		Bissau,,Guinée-Bissau /Meteo/Villes/intl/Pages/PUXX0001.htm
		Georgetown,,Guyana /Meteo/Villes/intl/Pages/GYXX0001.htm
		{Cayenne,,Guyane Française} /Meteo/Villes/intl/Pages/FGXX0001.htm
		Port-au-Prince,,Haïti /Meteo/Villes/intl/Pages/HAXX0004.htm
		{San Pedro Sula,,Honduras} /Meteo/Villes/intl/Pages/HOXX0007.htm
		Tegucigalpa,,Honduras /Meteo/Villes/intl/Pages/HOXX0008.htm
		Budapest,,Hongrie /Meteo/Villes/intl/Pages/HUXX0002.htm
		{George Town,,Îles Caïmanes} /Meteo/Villes/intl/Pages/CJXX0001.htm
		{Grand Cayman,,Îles Caïmanes} /Meteo/Villes/intl/Pages/CJXX0002.htm
		{Cocos Island Airport,,Îles Cocos (Keeling)} /Meteo/Villes/intl/Pages/KTXX0002.htm
		{Rarotonga,,Îles Cook} /Meteo/Villes/intl/Pages/CWXX0001.htm
		{Honiara,,Îles Salomon} /Meteo/Villes/intl/Pages/BPXX0001.htm
		{Providenciales,,Îles Turks et Caïques} /Meteo/Villes/intl/Pages/TCXX0002.htm
		{Saint-Thomas,,Îles Vierges des États-Unis} /Meteo/Villes/intl/Pages/VIXX0001.htm
		{Ahmadabad (Ahmedabad),,Inde} /Meteo/Villes/intl/Pages/INXX0001.htm
		Allahabad,,Inde /Meteo/Villes/intl/Pages/INXX0003.htm
		{Benares ,,Inde} /Meteo/Villes/intl/Pages/INXX0016.htm
		Calcutta,,Inde /Meteo/Villes/intl/Pages/INXX0028.htm
		Delhi,,Inde /Meteo/Villes/intl/Pages/INXX0038.htm
		Hyderabad,,Inde /Meteo/Villes/intl/Pages/INXX0057.htm
		Jaipur,,Inde /Meteo/Villes/intl/Pages/INXX0059.htm
		Kanpur,,Inde /Meteo/Villes/intl/Pages/INXX0067.htm
		Lucknow,,Inde /Meteo/Villes/intl/Pages/INXX0074.htm
		{Madras (Chennai),,Inde} /Meteo/Villes/intl/Pages/INXX0075.htm
		Mumbai,,Inde /Meteo/Villes/intl/Pages/INXX0026.htm
		Nagpur,,Inde /Meteo/Villes/intl/Pages/INXX0093.htm
		{New Delhi,,Inde} /Meteo/Villes/intl/Pages/INXX0096.htm
		Poona,,Inde /Meteo/Villes/intl/Pages/INXX0002.htm
		Bali,,Indonésie /Meteo/Villes/intl/Pages/IDXX0005.htm
		Bandung,,Indonésie /Meteo/Villes/intl/Pages/IDXX0007.htm
		Denpasar,,Indonésie /Meteo/Villes/intl/Pages/IDXX0019.htm
		Djakarta,,Indonésie /Meteo/Villes/intl/Pages/IDXX0022.htm
		Medan,,Indonésie /Meteo/Villes/intl/Pages/IDXX0033.htm
		Surabaya,,Indonésie /Meteo/Villes/intl/Pages/IDXX0052.htm
		{Téhéran,,Iran} /Meteo/Villes/intl/Pages/IRXX0018.htm
		Baghdad,,Iraq /Meteo/Villes/intl/Pages/IZXX0008.htm
		Cork,,Irlande /Meteo/Villes/intl/Pages/IEXX0003.htm
		Dublin,,Irlande /Meteo/Villes/intl/Pages/EIXX0014.htm
		Galway,,Irlande /Meteo/Villes/intl/Pages/IEXX0004.htm
		Limerick,,Irlande /Meteo/Villes/intl/Pages/IEXX0005.htm
		Shannon,,Irlande /Meteo/Villes/intl/Pages/IEXX0001.htm
		Reykjavik,,Islande /Meteo/Villes/intl/Pages/ICXX0002.htm
		Jérusalem,,Israël /Meteo/Villes/intl/Pages/ISXX0010.htm
		{Tel Aviv,,Israël} /Meteo/Villes/intl/Pages/ILXX0001.htm
		Bardonecchia,,Italie /Meteo/Villes/intl/Pages/ITXX0004.htm
		Bari,,Italie /Meteo/Villes/intl/Pages/ITXX0012.htm
		Bologna,,Italie /Meteo/Villes/intl/Pages/ITXX0006.htm
		Catane,,Italie /Meteo/Villes/intl/Pages/ITXX0011.htm
		Florence,,Italie /Meteo/Villes/intl/Pages/ITXX0028.htm
		Genes,,Italie /Meteo/Villes/intl/Pages/ITXX0010.htm
		Messine,,Italie /Meteo/Villes/intl/Pages/ITXX0013.htm
		Milan,,Italie /Meteo/Villes/intl/Pages/ITXX0042.htm
		Naples,,Italie /Meteo/Villes/intl/Pages/ITXX0052.htm
		Palermo,,Italie /Meteo/Villes/intl/Pages/ITXX0055.htm
		Pinerolo,,Italie /Meteo/Villes/intl/Pages/ITXX0003.htm
		Pragelato,,Italie /Meteo/Villes/intl/Pages/ITXX0005.htm
		{Prato Allo Stelv,,Italie} /Meteo/Villes/intl/Pages/ITXX0137.htm
		Prato,,Italie /Meteo/Villes/intl/Pages/ITXX0062.htm
		Rome,,Italie /Meteo/Villes/intl/Pages/ITXX0067.htm
		{Sauze D'Oulx,,Italie} /Meteo/Villes/intl/Pages/ITXX0008.htm
		Sestriere,,Italie /Meteo/Villes/intl/Pages/ITXX0007.htm
		Sicily,,Italie /Meteo/Villes/intl/Pages/ITXX0001.htm
		{Torre Pellice,,Italie} /Meteo/Villes/intl/Pages/ITXX0009.htm
		Turin,,Italie /Meteo/Villes/intl/Pages/ITXX0002.htm
		Venise,,Italie /Meteo/Villes/intl/Pages/ITXX0085.htm
		Verone,,Italie /Meteo/Villes/intl/Pages/ITXX0014.htm
		Falmouth,,Jamaïque /Meteo/Villes/intl/Pages/JMXX0001.htm
		Kingston,,Jamaïque /Meteo/Villes/intl/Pages/JMXX0002.htm
		{Montego Bay,,Jamaïque} /Meteo/Villes/intl/Pages/JMXX0003.htm
		Negril,,Jamaïque /Meteo/Villes/intl/Pages/JMXX0004.htm
		{Ocho Rios,,Jamaïque} /Meteo/Villes/intl/Pages/JMXX0005.htm
		{Runaway Bay,,Jamaïque} /Meteo/Villes/intl/Pages/JMXX0006.htm
		Akita,,Japon /Meteo/Villes/intl/Pages/JAXX0001.htm
		Aomori,,Japon /Meteo/Villes/intl/Pages/JAXX0004.htm
		Fukuoka,,Japon /Meteo/Villes/intl/Pages/JAXX0009.htm
		Hakodate,,Japon /Meteo/Villes/intl/Pages/JAXX0014.htm
		Hiroshima,,Japon /Meteo/Villes/intl/Pages/JAXX0018.htm
		Hokkaido,,Japon /Meteo/Villes/intl/Pages/JPXX0002.htm
		Kitakyushu,,Japon /Meteo/Villes/intl/Pages/JAXX0039.htm
		Kobe,,Japon /Meteo/Villes/intl/Pages/JAXX0040.htm
		{Kochi (Koti),,Japon} /Meteo/Villes/intl/Pages/JPXX0005.htm
		Kyoto,,Japon /Meteo/Villes/intl/Pages/JAXX0047.htm
		Kyushu,,Japon /Meteo/Villes/intl/Pages/JPXX0004.htm
		Miyazaki,,Japon /Meteo/Villes/intl/Pages/JAXX0110.htm
		Nagasaki,,Japon /Meteo/Villes/intl/Pages/JAXX0055.htm
		Nagoya,,Japon /Meteo/Villes/intl/Pages/JAXX0057.htm
		Oita,,Japon /Meteo/Villes/intl/Pages/JPXX0007.htm
		Osaka,,Japon /Meteo/Villes/intl/Pages/JAXX0071.htm
		Sapporo,,Japon /Meteo/Villes/intl/Pages/JAXX0078.htm
		Sendai,,Japon /Meteo/Villes/intl/Pages/JAXX0104.htm
		Tokyo,,Japon /Meteo/Villes/intl/Pages/JAXX0085.htm
		Toyama,,Japon /Meteo/Villes/intl/Pages/JPXX0003.htm
		Yokohama,,Japon /Meteo/Villes/intl/Pages/JAXX0099.htm
		Amman,,Jordanie /Meteo/Villes/intl/Pages/JOXX0002.htm
		{Alma Ata,,Kazakhstan} /Meteo/Villes/intl/Pages/KZXX0002.htm
		Almaty,,Kazakhstan /Meteo/Villes/intl/Pages/KZXX0001.htm
		Astana,,Kazakhstan /Meteo/Villes/intl/Pages/KZXX0003.htm
		Karaganda,,Kazakhstan /Meteo/Villes/intl/Pages/KZXX0004.htm
		Nairobi,,Kenya /Meteo/Villes/intl/Pages/KEXX0009.htm
		Koweït,,Koweït /Meteo/Villes/intl/Pages/KUXX0003.htm
		Bishkek,,Kyrgyzstan /Meteo/Villes/intl/Pages/KGXX0001.htm
		Maseru,,Lesotho /Meteo/Villes/intl/Pages/LTXX0001.htm
		Riga,,Lettonie /Meteo/Villes/intl/Pages/LGXX0004.htm
		Beyrouth,,Liban /Meteo/Villes/intl/Pages/LEXX0003.htm
		Monrovia,,Libéria /Meteo/Villes/intl/Pages/LIXX0002.htm
		Tripoli,,Libye /Meteo/Villes/intl/Pages/LYXX0009.htm
		Vilnius,,Lituanie /Meteo/Villes/intl/Pages/LHXX0005.htm
		Skopje,,Macedonie /Meteo/Villes/intl/Pages/MKXX0001.htm
		Antananarivo,,Madagascar /Meteo/Villes/intl/Pages/MAXX0002.htm
		{Kuala Lumpur,,Malaisie} /Meteo/Villes/intl/Pages/MYXX0008.htm
		Lilongwe,,Malawi /Meteo/Villes/intl/Pages/MIXX0002.htm
		Bamako,,Mali /Meteo/Villes/intl/Pages/MLXX0001.htm
		{La Valette,,Malte} /Meteo/Villes/intl/Pages/MTXX0005.htm
		Casablanca,,Maroc /Meteo/Villes/intl/Pages/MOXX0001.htm
		Marrakech,,Maroc /Meteo/Villes/intl/Pages/MAXX0007.htm
		Fort-de-France,,Martinique /Meteo/Villes/intl/Pages/MBXX0001.htm
		Acapulco,,Mexique /Meteo/Villes/intl/Pages/MXXX0001.htm
		Akumal,,Mexique /Meteo/Villes/intl/Pages/MXXX0002.htm
		{Baja California,,Mexique} /Meteo/Villes/intl/Pages/MXXX0007.htm
		{Cabo San Lucas,,Mexique} /Meteo/Villes/intl/Pages/MXXX0010.htm
		Cancun,,Mexique /Meteo/Villes/intl/Pages/MXXX0014.htm
		{Ciudad Constitución,,Mexique} /Meteo/Villes/intl/Pages/MXXX0006.htm
		Cozumel,,Mexique /Meteo/Villes/intl/Pages/MXXX0038.htm
		{Ecatepec de Morelos,,Mexique} /Meteo/Villes/intl/Pages/MXXX0009.htm
		Guadalajara,,Mexique /Meteo/Villes/intl/Pages/MXXX0050.htm
		Huatulco,,Mexique /Meteo/Villes/intl/Pages/MXXX0169.htm
		Ixtapa/Zihuatanejo,,Mexique /Meteo/Villes/intl/Pages/MXXX0168.htm
		Ixtapa,,Mexique /Meteo/Villes/intl/Pages/MXXX0161.htm
		{La Paz,,Mexique} /Meteo/Villes/intl/Pages/MXXX0065.htm
		{Leon de los Aldamas,,Mexique} /Meteo/Villes/intl/Pages/MXXX0011.htm
		Loreto,,Mexique /Meteo/Villes/intl/Pages/MXXX0069.htm
		{Los Cabos,,Mexique} /Meteo/Villes/intl/Pages/MXXX0070.htm
		Manzanillo,,Mexique /Meteo/Villes/intl/Pages/MXXX0074.htm
		Mazatlan,,Mexique /Meteo/Villes/intl/Pages/MXXX0076.htm
		Mexico,,Mexique /Meteo/Villes/intl/Pages/MXXX0079.htm
		Monterrey,,Mexique /Meteo/Villes/intl/Pages/MXXX0082.htm
		{Playa del Carmen,,Mexique} /Meteo/Villes/intl/Pages/MXXX0099.htm
		Puebla,,Mexique /Meteo/Villes/intl/Pages/MXXX0003.htm
		{Puerto Morelos,,Mexique} /Meteo/Villes/intl/Pages/MXXX0106.htm
		{Puerto Vallarta,,Mexique} /Meteo/Villes/intl/Pages/MXXX0108.htm
		Rosarito,,Mexique /Meteo/Villes/intl/Pages/MXXX0163.htm
		Tijuana,,Mexique /Meteo/Villes/intl/Pages/MXXX0136.htm
		{Tuxtla Gutierrez,,Mexique} /Meteo/Villes/intl/Pages/MXXX0146.htm
		Veracruz,,Mexique /Meteo/Villes/intl/Pages/MXXX0149.htm
		Monaco,,Monaco /Meteo/Villes/intl/Pages/MNXX0001.htm
		{Oulan Bator,,Mongolie} /Meteo/Villes/intl/Pages/MNXX0002.htm
		Maputo,,Mozambique /Meteo/Villes/intl/Pages/MZXX0003.htm
		Rangoon,,Myanmar /Meteo/Villes/intl/Pages/MMXX0001.htm
		Yangon,,Myanmar /Meteo/Villes/intl/Pages/BMXX0005.htm
		Windhoek,,Namibie /Meteo/Villes/intl/Pages/WAXX0004.htm
		Yaren,,Nauru /Meteo/Villes/intl/Pages/NRXX0001.htm
		{Camp de Base de l'Everest,,Népal} /Meteo/Villes/intl/Pages/NPXX0004.htm
		Katmandou,,Népal /Meteo/Villes/intl/Pages/NPXX0005.htm
		{Sommet de l'Everest,,Népal} /Meteo/Villes/intl/Pages/NPXX0006.htm
		Managua,,Nicaragua /Meteo/Villes/intl/Pages/NUXX0004.htm
		Lagos,,Nigéria /Meteo/Villes/intl/Pages/NGLA0001.htm
		Niamey,,Niger /Meteo/Villes/intl/Pages/NGXX0003.htm
		Bergen,,Norvège /Meteo/Villes/intl/Pages/NOXX0004.htm
		Oslo,,Norvège /Meteo/Villes/intl/Pages/NOXX0029.htm
		Auckland,,Nouvelle-Zélande /Meteo/Villes/intl/Pages/NZXX0003.htm
		Christchurch,,Nouvelle-Zélande /Meteo/Villes/intl/Pages/NZXX0002.htm
		Dunedin,,Nouvelle-Zélande /Meteo/Villes/intl/Pages/NZXX0004.htm
		Hamilton,,Nouvelle-Zélande /Meteo/Villes/intl/Pages/NZXX0005.htm
		Wellington,,Nouvelle-Zélande /Meteo/Villes/intl/Pages/NZXX0049.htm
		Mascate,,Oman /Meteo/Villes/intl/Pages/MUXX0003.htm
		Kampala,,Ouganda /Meteo/Villes/intl/Pages/UGXX0001.htm
		Islamabad,,Pakistan /Meteo/Villes/intl/Pages/PKXX0006.htm
		Karachi,,Pakistan /Meteo/Villes/intl/Pages/PKXX0008.htm
		{Panama City,,Panama} /Meteo/Villes/intl/Pages/PMXX0004.htm
		{Port Moresby,,Papouasie-Nouvelle-Guinée} /Meteo/Villes/intl/Pages/PPXX0004.htm
		Asunción,,Paraguay /Meteo/Villes/intl/Pages/PAXX0001.htm
		Amsterdam,,Pays-Bas /Meteo/Villes/intl/Pages/NLXX0002.htm
		Lima,,Pérou /Meteo/Villes/intl/Pages/PEXX0011.htm
		Aparri,,Philippines /Meteo/Villes/intl/Pages/RPXX0042.htm
		{Cebu City,,Philippines} /Meteo/Villes/intl/Pages/RPXX0007.htm
		Davao,,Philippines /Meteo/Villes/intl/Pages/RPXX0008.htm
		Iloilo,,Philippines /Meteo/Villes/intl/Pages/RPXX0012.htm
		Laoag,,Philippines /Meteo/Villes/intl/Pages/RPXX0041.htm
		Manille,,Philippines /Meteo/Villes/intl/Pages/RPXX0017.htm
		{Quezon City,,Philippines} /Meteo/Villes/intl/Pages/RPXX0027.htm
		Zamboanga,,Philippines /Meteo/Villes/intl/Pages/RPXX0037.htm
		Cracow,,Pologne /Meteo/Villes/intl/Pages/PLXX0001.htm
		Gdansk,,Pologne /Meteo/Villes/intl/Pages/PLXX0005.htm
		Lodz,,Pologne /Meteo/Villes/intl/Pages/PLXX0002.htm
		Poznan,,Pologne /Meteo/Villes/intl/Pages/PLXX0004.htm
		Varsovie,,Pologne /Meteo/Villes/intl/Pages/PLXX0028.htm
		Wroclaw,,Pologne /Meteo/Villes/intl/Pages/PLXX0003.htm
		{Aguadilla,,Porto Rico} /Meteo/Villes/intl/Pages/USPR0003.htm
		{San Juan,,Porto Rico} /Meteo/Villes/intl/Pages/PRXX0001.htm
		Amadora,,Portugal /Meteo/Villes/intl/Pages/PTXX0001.htm
		Braga,,Portugal /Meteo/Villes/intl/Pages/PTXX0002.htm
		Lisbonne,,Portugal /Meteo/Villes/intl/Pages/POXX0016.htm
		{Ponta Delgada,,Portugal} /Meteo/Villes/intl/Pages/POXX0020.htm
		Porto,,Portugal /Meteo/Villes/intl/Pages/POXX0022.htm
		Setubal,,Portugal /Meteo/Villes/intl/Pages/PTXX0003.htm
		Doha,,Qatar /Meteo/Villes/intl/Pages/QAXX0001.htm
		{Bangui,,République Centrafricaine} /Meteo/Villes/intl/Pages/CTXX0001.htm
		{Barahona,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0001.htm
		{Bayahibe,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0004.htm
		{Boca Chica,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0001.htm
		{Cabarete,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0007.htm
		{Juan Dolio,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0005.htm
		{La Romana,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0003.htm
		{Puerto Plata,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0005.htm
		{Punta Cana,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0003.htm
		{San Cristobal,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0009.htm
		{San Francisco de Macoris,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0008.htm
		{San Pedro de Macoris,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0007.htm
		{Santiago,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0008.htm
		{Santo Domingo,,République dominicaine} /Meteo/Villes/intl/Pages/DRXX0009.htm
		{Sosua,,République dominicaine} /Meteo/Villes/intl/Pages/DOXX0006.htm
		Bucarest,,Roumanie /Meteo/Villes/intl/Pages/ROXX0003.htm
		Aberdeen,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0001.htm
		Belfast,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0015.htm
		Birmingham,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0018.htm
		Bradford,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0006.htm
		Bristol,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0007.htm
		Cardiff,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0030.htm
		Coventry,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0010.htm
		Édimbourg,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0052.htm
		Glasgow,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0061.htm
		Leeds,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0003.htm
		Leicester,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0009.htm
		Liverpool,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0083.htm
		Londres,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0085.htm
		Manchester,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0092.htm
		Newcastle,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0098.htm
		Norwich,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0103.htm
		Nottingham,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0008.htm
		Plymouth,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0112.htm
		Salisbury,,Royaume-Uni /Meteo/Villes/intl/Pages/UKXX0301.htm
		Sheffield,,Royaume-Uni /Meteo/Villes/intl/Pages/GBXX0005.htm
		{Chelyabinsk,,Russie} /Meteo/Villes/intl/Pages/RSXX0024.htm
		{Kazan',,Russie} /Meteo/Villes/intl/Pages/RSXX0043.htm
		{Moscou,,Russie} /Meteo/Villes/intl/Pages/RSXX0063.htm
		{Nizhny Novgorod,,Russie} /Meteo/Villes/intl/Pages/RSXX0069.htm
		{Perm',,Russie} /Meteo/Villes/intl/Pages/RSXX0082.htm
		{Saint-Pétersbourg,,Russie} /Meteo/Villes/intl/Pages/RUXX0001.htm
		{Saratov,,Russie} /Meteo/Villes/intl/Pages/RSXX0414.htm
		{Ufa,,Russie} /Meteo/Villes/intl/Pages/RSXX0111.htm
		{Volgograd,,Russie} /Meteo/Villes/intl/Pages/RSXX0117.htm
		{Voronez,,Russie} /Meteo/Villes/intl/Pages/RSXX0412.htm
		{Yekaterinburg,,Russie} /Meteo/Villes/intl/Pages/RSXX0123.htm
		Kigali,,Rwanda /Meteo/Villes/intl/Pages/RWXX0001.htm
		Basseterre,,Saint-Kitts-Et-Nevis /Meteo/Villes/intl/Pages/SCXX0001.htm
		Miquelon,,Saint-Pierre-et-Miquelon /Meteo/Villes/intl/Pages/PMXX0009.htm
		{Saint Pierre,,Saint-Pierre-et-Miquelon} /Meteo/Villes/intl/Pages/PMXX0008.htm
		{Kingstown,,Saint-Vincent-et-les Grenadines} /Meteo/Villes/intl/Pages/VCXX0001.htm
		Castries,,Sainte-Lucie /Meteo/Villes/intl/Pages/STXX0001.htm
		Dakar,,Sénégal /Meteo/Villes/intl/Pages/SGXX0001.htm
		{Belgrade,,Serbie et Monténégro} /Meteo/Villes/intl/Pages/SRXX0001.htm
		{Freetown,,Sierra Leone} /Meteo/Villes/intl/Pages/SLXX0001.htm
		Singapour,,Singapour /Meteo/Villes/intl/Pages/SNXX0006.htm
		Bratislava,,Slovaquie /Meteo/Villes/intl/Pages/LOXX0001.htm
		Ljubljana,,Slovénie /Meteo/Villes/intl/Pages/SIXX0002.htm
		Maribor,,Slovénie /Meteo/Villes/intl/Pages/SIXX0004.htm
		Mogadishu,,Somalie /Meteo/Villes/intl/Pages/SOXX0002.htm
		Khartoum,,Soudan /Meteo/Villes/intl/Pages/SUXX0002.htm
		{Colombo (Kolamba),,Sri Lanka} /Meteo/Villes/intl/Pages/CEXX0001.htm
		Stockholm,,Suède /Meteo/Villes/intl/Pages/SWXX0031.htm
		Genève,,Suisse /Meteo/Villes/intl/Pages/SZXX0013.htm
		Zurich,,Suisse /Meteo/Villes/intl/Pages/SZXX0033.htm
		Paramaribo,,Suriname /Meteo/Villes/intl/Pages/NSXX0002.htm
		Damas,,Syrie /Meteo/Villes/intl/Pages/SYXX0004.htm
		Dushanbe,,Tadjikistan /Meteo/Villes/intl/Pages/TIXX0001.htm
		Papeete,,Tahiti /Meteo/Villes/intl/Pages/PFXX0001.htm
		{Kao-Hsiung,,Taïwan} /Meteo/Villes/intl/Pages/TWXX0013.htm
		{T'ai-Chung,,Taïwan} /Meteo/Villes/intl/Pages/TWXX0019.htm
		{Taipei,,Taïwan} /Meteo/Villes/intl/Pages/TWXX0021.htm
		{Dar Es-Salaam,,Tanzanie} /Meteo/Villes/intl/Pages/TZXX0001.htm
		N'Djamena,,Tchad /Meteo/Villes/intl/Pages/CDXX0003.htm
		NDjamena,,Tchad /Meteo/Villes/intl/Pages/TDXX0002.htm
		{Prague,,Tchèque République} /Meteo/Villes/intl/Pages/EZXX0012.htm
		Bangkok,,Thaïlande /Meteo/Villes/intl/Pages/THXX0002.htm
		{Chiang Mai,,Thaïlande} /Meteo/Villes/intl/Pages/THXX0003.htm
		Lome,,Togo /Meteo/Villes/intl/Pages/TOXX0001.htm
		{Port of Spain,,Trinité-et-Tobago} /Meteo/Villes/intl/Pages/TTXX0001.htm
		Scarborough,,Trinité-et-Tobago /Meteo/Villes/intl/Pages/TDXX0001.htm
		Tunis,,Tunisie /Meteo/Villes/intl/Pages/TSXX0010.htm
		Ashkhabad,,Turkménistan /Meteo/Villes/intl/Pages/TXXX0001.htm
		Ankara,,Turquie /Meteo/Villes/intl/Pages/TUXX0002.htm
		Istanbul,,Turquie /Meteo/Villes/intl/Pages/TUXX0014.htm
		Kiev,,Ukraine /Meteo/Villes/intl/Pages/UAXX0001.htm
		Odessa,,Ukraine /Meteo/Villes/intl/Pages/UPXX0021.htm
		Montevideo,,Uruguay /Meteo/Villes/intl/Pages/UYXX0006.htm
		Tashkent,,Uzbekistan /Meteo/Villes/intl/Pages/UZXX0004.htm
		Barcelone,,Venezuela /Meteo/Villes/intl/Pages/VEXX0002.htm
		Caracas,,Venezuela /Meteo/Villes/intl/Pages/VEXX0008.htm
		{Ile Margarita,,Venezuela} /Meteo/Villes/intl/Pages/VEXX0038.htm
		Maracaibo,,Venezuela /Meteo/Villes/intl/Pages/VEXX0018.htm
		{Puerto La Cruz,,Venezuela} /Meteo/Villes/intl/Pages/VEXX0025.htm
		{Can Tho,,Viêt Nam} /Meteo/Villes/intl/Pages/VMXX0004.htm
		{Da Nang,,Viêt Nam} /Meteo/Villes/intl/Pages/VMXX0028.htm
		{Hanoi,,Viêt Nam} /Meteo/Villes/intl/Pages/VMXX0006.htm
		{Hô Chi Minh-Ville,,Viêt Nam} /Meteo/Villes/intl/Pages/VMXX0007.htm
		{Hue,,Viêt Nam} /Meteo/Villes/intl/Pages/VMXX0009.htm
		{Jerusalem,,West Bank} /Meteo/Villes/intl/Pages/WBXX0001.htm
		Sanaa,,Yémen /Meteo/Villes/intl/Pages/YEXX0001.htm
		Lusaka,,Zambie /Meteo/Villes/intl/Pages/ZAXX0004.htm
		Harare,,Zimbabwe /Meteo/Villes/intl/Pages/ZIXX0004.htm
	}

	## http callback
	proc callback {chan nick location token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {ok} $status]} {
			switch -exact -- $status {
				timeout {
					puthelp "PRIVMSG $chan :\[\002$nick\002\] Timeout (60 seconds) on connection to server, please try again later."
					::lephttp::cleanup $token; return
				}
				default {
					puthelp "PRIVMSG $chan :\[\002$nick\002\] Unknown error has occured, server output of the error is as follows: $status"
					::lephttp::cleanup $token; return
				}
			}
		}
		## parse and output info
		regexp -all -- {\=displayObs\((.+?)\)\;} [::lephttp::data $token] x y; ::lephttp::cleanup $token
		foreach index {1 2 3 6 7 8 11 13 14 15 16 20 24 25} var {loc dt tm wd wkt wkm bp tempc tempf dpc dpf hum viskm vismi} {
			set $var [::lephttp::strip [::lephttp::map [string trim [lindex [split [string map {{"} {}} $y] ,] $index]]]]
		}
		putserv "PRIVMSG $chan :[join $location] - \002Temp:\002 $tempc \002Vents:\002 $wkm $wd"
		putserv "PRIVMSG $chan :\002Humidite:\002 $hum \002Point de Rosee:\002 $dpc \002Pression:\002 $bp \002Visibilte:\002 $viskm"
		putserv "PRIVMSG $chan :Emis le: $dt, [lindex [split $tm] 0] - $loc"
	}
	
	## pub command handler
	proc pubMeteo {nick uhost hand chan text} {
		if {[channel get $chan nometeo]} {return}
		if {[string equal {} [set text [string trim $text]]]} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !meteo <city, location>"; return
		}
		## split em up and trim extra space
		foreach {city location} [split $text ,] {set city [string trim $city]; set location [string trim $location]}
		## lookup our location information...foreach is slower than array get
		## but we need a case insensitive search cause we don't trust irc input
		foreach name [array names ::meteomedia::locids] {if {[string match -nocase $city*$location* $name]} {array set results [array get ::meteomedia::locids $name]}}
		if {[array size results] > 1} {
			set i 0; foreach name [array names results] {
				foreach {city prov cont} [split $name ,] {}
				if {![string length $prov]} {
					lappend places [join [list $city $cont] {, }]
				} else {
					lappend places [join [list $city $prov $cont] {, }]
				}; if {[incr i] > 5} {break}
			}
			putserv "PRIVMSG $chan :\[\002$nick\002\] Sorry, I couldn't find an exact match for that location.  Please try one of the following: [join $places { - }]"
		} elseif {[array size results] < 1} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Sorry, I couldn't find any locations that matched your request."
		} else {
			foreach {city prov cont} [split [array names results] ,] {}
			if {![string length $prov]} {set location [join [list $city $cont] {, }]} else {set location [join [list $city $prov $cont] {, }]}
			::lephttp::fetch http://www.meteomedia.com[lindex [array get results] end] -command [list ::meteomedia::callback $chan $nick $location] -timeout 60000
		}
	}
	bind pub - !meteo ::meteomedia::pubMeteo; bind pub - .meteo ::meteo::pubMeteo
}
package provide meteomedia 0.1

putlog "Loaded meteomedia.tcl v0.1 by leprechau@EFNet!"
