cd ./programs/MultiSupportProgram/multi_dao_support_program
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/DaoManager/daom__approved_proposers_001
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/DaoManager/daom__no_approval_required
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/DaoManagerUpdater/daomu__dao_based
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_ap_001
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/VotingSystemManager/vsm__dao_based_nar
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/ProposersManager/psm__dao_based_001
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/DaoFactories/zvote_dao_factory_002
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/VotingSystem/vs__2_candidates
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../..

cd ./programs/TriggeredOnApproval/Treasury/treasury__dao_based_001
leo build --network testnet --endpoint "https://api.explorer.aleo.org/v1"
cd ../../../..

