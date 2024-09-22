
source ./development/.env

SLEEP_BETWEEN_TX=10

deploy_any () {
    build_path="$1/$2/build"
    cd $build_path;
    snarkos developer deploy \
        --private-key $PRIVATE_KEY \
        --query $NODE_URL \
        --priority-fee 0 \
        --broadcast "$NODE_URL/$NETWORK/transaction/broadcast" \
        --network 1 \
        "$2.aleo";
    only_slash="${build_path//[^\/]}";
    slash_amount="${#only_slash}";
    back_steps=$(printf '../%.0s' $(seq 1 $slash_amount));
    cd $back_steps;
}

deploy_program () {
    deploy_any "./programs" $1;
    sleep $SLEEP_BETWEEN_TX;
}


deploy_any "./programs/Registry" "zvote_dao_registry";
deploy_any "./programs/DaoManager" "daom__no_approval_003";
deploy_any "./programs/DaoManagerUpdater" "daomu__dao_based_003";
deploy_any "./programs/VotingSystemManager" "vsm__dao_based_na_003";
deploy_any "./programs/DaoManager" "daom__approved_proposers_003";
deploy_any "./programs/VotingSystemManager" "vsm__dao_based_ap_003";
deploy_any "./programs/ProposersManager" "psm__dao_based_003";
deploy_any "./programs/DaoFactories" "zvote_dao_factory_003";
deploy_any "./programs/TriggeredOnApproval/Treasury" "treasury__dao_based_003";
deploy_any "./programs/VotingSystem" "vs__2_candidates_003";


