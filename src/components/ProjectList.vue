<template>
  <!-- eslint-disable -->
  <v-container grid-list-lg>
    <h1 class="display-1 font-weight-bold mb-3">Projects</h1>
    <v-layout row wrap>
      <v-flex v-for="(project, index) in projects" :key="index" xs12 sm6 lg4>
        <v-dialog v-model="project.dialog" width="800">
          <v-card>
            <v-card-title class="headline font-weight-bold">{{ project.title }}</v-card-title>
            <v-card-text>{{ project.description }}</v-card-text>
            <v-card-actions>
              <v-spacer />
              <v-btn color="blue darken-1" text @click="projects[index].dialog = false">Close</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-hover>
          <v-card slot-scope="{ hover }" :class="`elevation-${hover ? 10 : 2}`" height="100%">
            <v-card-title primary-title>
              <div class="title font-weight-bold">
                <v-chip
                  label
                  :color="stateMap[project.state].color"
                  text-color="white"
                  class="mt-0"
                >{{ stateMap[project.state].text }}</v-chip>
                {{ project.title }}
              </div>
            </v-card-title>
            <v-flex class="pa-5">
              <span>{{ project.description.substring(0, 100) }}</span>
              <span v-if="project.description.length > 100">
                ...
                <a @click="projects[index].dialog = true">[Show full]</a>
              </span>
              <br />
              <br />
              <div class="subtitle-2">Deliverables:</div>
              <ol>
                <li
                  v-for="(milestone, index) in project.milestones"
                  :key="index"
                >{{ milestone.deliverable }}</li>
              </ol>
              <br />
              <small>
                Up Until:
                <b>{{ new Date(project.fundraisingDeadline * 1000) }}</b>
              </small>
            </v-flex>
            <v-flex class="d-flex text-center align-center" v-if="project.state != 2">
              <span
                class="font-weight-bold"
                style="width: 200px;"
              >{{ project.currentBalance / 10**18 }} ETH</span>
              <v-progress-linear
                height="10"
                :color="stateMap[project.state].color"
                :value="project.currentBalance / project.goalAmount * 100"
              ></v-progress-linear>
              <span
                class="font-weight-bold"
                style="width: 200px;"
              >{{ project.goalAmount / 10**18 }} ETH</span>
            </v-flex>
            <v-flex class="text-center">
              <span>Goal of&nbsp;</span>
              <b>{{ project.goalAmount / 10**18 }} ETH&nbsp;</b>
              <small v-if="project.state == 1">wasn't achieved before deadline</small>
              <small v-if="project.state == 2">has been achieved</small>
            </v-flex>
            <v-flex v-if="project.state == 2 && project.contributions > 0" class="text-center">
              <div class="subtitle-2">Vote on Progress</div>
              <v-btn class="error ma-2">Bad</v-btn>
              <v-btn class="success ma-2">Good</v-btn>
            </v-flex>
            <v-flex v-if="project.state == 0 && account != project.creator" class="d-flex ml-2">
              <v-text-field
                label="Amount (in ETH)"
                class="mt-0"
                type="number"
                step="0.0001"
                min="0"
                v-model="project.amountToFund"
              ></v-text-field>
              <v-btn
                class="mt-2"
                color="light-blue darken-1 white--text"
                @click="fundProject(index)"
                :loading="project.isLoading"
              >Fund</v-btn>
            </v-flex>
            <v-card-actions v-if="project.state == 1">
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
import web3 from "@/plugins/web3";
import contract from "truffle-contract";
import CrowdfundABI from "@/contracts/Crowdfund";

const Crowdfund = contract(CrowdfundABI);
Crowdfund.setProvider(web3.currentProvider);

export default {
  data() {
    return {
      account: null,
      crowdfund: null,
      projects: [],
      stateMap: [
        { color: "primary", text: "Ongoing" },
        { color: "warning", text: "Expired" },
        { color: "success", text: "Funded" }
      ]
    };
  },
  async mounted() {
    [this.account] = await web3.eth.getAccounts();
    this.crowdfund = await Crowdfund.deployed();
    this.getProjects();
  },
  methods: {
    async getProjects() {
      const projectCount = await this.crowdfund.projectCount();

      for (let projectId = 0; projectId < projectCount; projectId++) {
        let project = await this.crowdfund.projects(projectId);
        let milestones = [];

        const milestoneCount = await this.crowdfund.projectMilestoneCount(
          projectId
        );

        for (let index = 0; index < milestoneCount; index++) {
          const milestoneId = await this.crowdfund.projectMilestones(
            projectId,
            index
          );
          milestones.push(await this.crowdfund.milestones(milestoneId));
        }

        const contributions =
          (await this.crowdfund.getContributions(projectId, {
            from: this.account
          })) /
          10 ** 18;

        this.projects.push({ ...project, milestones, contributions });
      }
    },
    fundProject(projectId) {
      if (!this.projects[projectId].amountToFund) {
        return;
      }
      this.projects[projectId].isLoading = true;
      this.crowdfund.contribute(projectId, {
        from: this.account,
        value: web3.utils.toWei(this.projects[projectId].amountToFund, "ether")
      });
      // .then(res => {
      //   const newTotal = parseInt(
      //     res.events.FundingReceived.returnValues.currentTotal,
      //     10
      //   );
      //   const projectGoal = parseInt(
      //     this.projects[projectId].goalAmount,
      //     10
      //   );
      //   this.projects[projectId].currentBalance = newTotal;
      //   this.projects[projectId].isLoading = false;
      //   // Set project state to success
      //   if (newTotal >= projectGoal) {
      //     this.projects[projectId].currentState = 2;
      //   }
      // });
    }
    // getRefund(index) {
    //   this.projects[index].isLoading = true;
    //   this.projects[index].contract.methods
    //     .getRefund()
    //     .send({
    //       from: this.account
    //     })
    //     .then(() => {
    //       this.projects[index].isLoading = false;
    //     });
    // }
  }
};
</script>
