source ./development/.env

cd ./programs/Registry/zvote_dao_registry_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManager/daom__approved_proposers_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManager/daom__no_approval_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManagerUpdater/daomu__dao_based_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_ap_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_na_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/ProposersManager/psm__dao_based_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoFactories/zvote_dao_factory_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystem/vs__2_candidates_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/TriggeredOnApproval/Treasury/treasury__dao_based_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../../..


cd ./programs/Helper/h__update_daom_helper_008
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../../