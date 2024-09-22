source ./development/.env

cd ./programs/Registry/zvote_dao_registry
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManager/daom__approved_proposers_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManager/daom__no_approval_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoManagerUpdater/daomu__dao_based_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_ap_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_na_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/ProposersManager/psm__dao_based_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/DaoFactories/zvote_dao_factory_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/VotingSystem/vs__2_candidates_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../..

cd ./programs/TriggeredOnApproval/Treasury/treasury__dao_based_003
leo build --network $NETWORK --endpoint $NODE_URL
cd ../../../..

