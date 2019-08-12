<template>
  <!-- eslint-disable -->
  <v-container grid-list-lg>
    <h1 class="display-1 font-weight-bold mb-3">Projects</h1>
    <v-layout row wrap>
      <v-flex v-for="(project, index) in projectData" :key="index" xs12 sm6 lg4>
        <v-dialog v-model="project.dialog" width="800">
          <v-card>
            <v-card-title class="headline font-weight-bold">{{ project.projectTitle }}</v-card-title>
            <v-card-text>{{ project.projectDesc }}</v-card-text>
            <v-card-actions>
              <v-spacer />
              <v-btn color="blue darken-1" text @click="projectData[index].dialog = false">Close</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-hover>
          <v-card slot-scope="{ hover }" :class="`elevation-${hover ? 10 : 2}`" height="100%">
            <v-card-title primary-title>
              <div>
                <div class="headline font-weight-bold">
                  <v-chip
                    label
                    :color="stateMap[project.currentState].color"
                    text-color="white"
                    class="mt-0"
                  >{{ stateMap[project.currentState].text }}</v-chip>
                  {{ project.projectTitle }}
                </div>
                <br />
                <span>{{ project.projectDesc.substring(0, 100) }}</span>
                <span v-if="project.projectDesc.length > 100">
                  ...
                  <a @click="projectData[index].dialog = true">[Show full]</a>
                </span>
                <br />
                <br />
                <small>
                  Up Until:
                  <b>{{ new Date(project.deadline * 1000) }}</b>
                </small>
                <br />
                <br />
                <small>
                  Goal of
                  <b>{{ project.goalAmount / 10**18 }} ETH&nbsp;</b>
                </small>
                <small v-if="project.currentState == 1">wasn't achieved before deadline</small>
                <small v-if="project.currentState == 2">has been achieved</small>
              </div>
            </v-card-title>
            <v-flex class="d-flex text-xs-center align-center" v-if="project.currentState != 2">
              <span
                class="font-weight-bold"
                style="width: 200px;"
              >{{ project.currentAmount / 10**18 }} ETH</span>
              <v-progress-linear
                height="10"
                :color="stateMap[project.currentState].color"
                :value="project.currentAmount / project.goalAmount * 100"
              ></v-progress-linear>
              <span
                class="font-weight-bold"
                style="width: 200px;"
              >{{ project.goalAmount / 10**18 }} ETH</span>
            </v-flex>
            <v-flex
              v-if="project.currentState == 0 && account != project.projectStarter"
              class="d-flex ml-2"
            >
              <v-text-field
                label="Amount (in ETH)"
                class="mt-0"
                type="number"
                step="0.0001"
                min="0"
                v-model="project.fundAmount"
              ></v-text-field>
              <v-btn
                class="mt-2"
                color="light-blue darken-1 white--text"
                @click="fundProject(index)"
                :loading="project.isLoading"
              >Fund</v-btn>
            </v-flex>
            <v-card-actions v-if="project.currentState == 1">
              <v-flex class="d-flex xs12 mb-2">
                <v-btn
                  color="amber darken-1 white--text"
                  @click="getRefund(index)"
                  :loading="project.isLoading"
                >Get refund</v-btn>
              </v-flex>
            </v-card-actions>
          </v-card>
        </v-hover>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
// import crowdfundInstance from "../../contracts/crowdfundInstance";
// import crowdfundProject from "../../contracts/crowdfundProjectInstance";
// import web3 from "../../contracts/web3";

export default {
  data() {
    return {
      account: null,
      projectData: [],
      stateMap: [
        { color: "primary", text: "Ongoing" },
        { color: "warning", text: "Expired" },
        { color: "success", text: "Funded" }
      ]
    };
  },
  mounted() {
    // web3.eth.getAccounts().then(accounts => {
    //   [this.account] = accounts;
    //   this.getProjects();
    // });
  },
  methods: {
    getProjects() {
      //   crowdfundInstance.methods
      //     .returnAllProjects()
      //     .call()
      //     .then(projects => {
      //       projects.forEach(projectAddress => {
      //         const projectInst = crowdfundProject(projectAddress);
      //         projectInst.methods
      //           .getDetails()
      //           .call()
      //           .then(projectData => {
      //             const projectInfo = projectData;
      //             projectInfo.isLoading = false;
      //             projectInfo.contract = projectInst;
      //             this.projectData.push(projectInfo);
      //           });
      //       });
      //     });
    }
    // fundProject(index) {
    //   if (!this.projectData[index].fundAmount) {
    //     return;
    //   }
    //   const projectContract = this.projectData[index].contract;
    //   this.projectData[index].isLoading = true;
    //   projectContract.methods
    //     .contribute()
    //     .send({
    //       from: this.account,
    //       value: web3.utils.toWei(this.projectData[index].fundAmount, "ether")
    //     })
    //     .then(res => {
    //       const newTotal = parseInt(
    //         res.events.FundingReceived.returnValues.currentTotal,
    //         10
    //       );
    //       const projectGoal = parseInt(this.projectData[index].goalAmount, 10);
    //       this.projectData[index].currentAmount = newTotal;
    //       this.projectData[index].isLoading = false;
    //       // Set project state to success
    //       if (newTotal >= projectGoal) {
    //         this.projectData[index].currentState = 2;
    //       }
    //     });
    // },
    // getRefund(index) {
    //   this.projectData[index].isLoading = true;
    //   this.projectData[index].contract.methods
    //     .getRefund()
    //     .send({
    //       from: this.account
    //     })
    //     .then(() => {
    //       this.projectData[index].isLoading = false;
    //     });
    // }
  }
};
</script>
