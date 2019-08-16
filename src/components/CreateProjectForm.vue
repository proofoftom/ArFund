<template>
  <!-- eslint-disable -->
  <v-card>
    <v-card-title>
      <span class="headline font-weight-bold mt-2 ml-4">Bring your project to life</span>
    </v-card-title>
    <v-card-text class="pt-0">
      <v-container class="pt-0" grid-list-xl>
        <v-layout wrap>
          <v-flex xs12>
            <v-text-field
              label="Project"
              persistent-hint
              v-model="newProject.title"
              placeholder="Title"
            />
          </v-flex>
          <v-flex xs12>
            <v-textarea
              label="Description"
              persistent-hint
              v-model="newProject.description"
              placeholder="What's the goal of the project?"
            />
          </v-flex>
          <v-flex xs12>
            <v-text-field
              label="Time to Fundraise"
              persistent-hint
              v-model="newProject.daysToFundraise"
              placeholder="Numer of days to fundraise"
            />
          </v-flex>
          <span class="title font-weight-bold mt-2">Milestones</span>
          <v-layout wrap v-for="(milestone, index) in newProject.milestones" :key="index">
            <v-flex xs12 sm8>
              <v-text-field
                label="Deliverable"
                v-model="milestone.title"
                placeholder="What's the deliverable of this milestone?"
              />
            </v-flex>
            <v-flex xs12 sm2>
              <v-text-field
                label="Cost"
                type="number"
                step=".01"
                min="0"
                v-model="milestone.goalAmount"
                placeholder="Ξ Goal"
              />
            </v-flex>
            <v-flex xs12 sm2>
              <v-text-field
                label="Duration"
                type="number"
                v-model="milestone.duration"
                placeholder="Days"
              />
            </v-flex>
          </v-layout>
          <v-spacer />
          <v-btn @click="addMilestone">Add Milestone</v-btn>
        </v-layout>
      </v-container>
    </v-card-text>
    <v-card-actions>
      <v-spacer />
      <v-btn
        color="blue darken-1"
        text
        @click="$emit('closeDialog');
                newProject = { isLoading: false, milestones: [{}] }"
      >Cancel</v-btn>
      <v-btn
        color="blue darken-1"
        text
        @click="createProject"
        :loading="newProject.isLoading"
      >Create</v-btn>
    </v-card-actions>
  </v-card>
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
      newProject: {
        isLoading: false,
        milestones: [{}]
      }
    };
  },
  async mounted() {
    [this.account] = await web3.eth.getAccounts();
    this.crowdfund = await Crowdfund.deployed();
  },
  methods: {
    createProject() {
      this.newProject.isLoading = true;

      this.crowdfund
        // First create project...
        .createProject(
          this.newProject.title,
          this.newProject.description,
          this.newProject.daysToFundraise,
          {
            from: this.account
          }
        )
        .then(async () => {
          // then get project id...
          const projectId = (await this.crowdfund.projectCount()) - 1;

          // then create and attach all of the milestones to project.
          this.newProject.milestones.forEach((milestone, index) => {
            this.crowdfund
              .createMilestone(
                projectId,
                milestone.title,
                web3.utils.toWei(milestone.goalAmount, "ether"),
                milestone.duration,
                {
                  from: this.account
                }
              )
              .then(() => {
                // If this is the last milestone, close dialog.
                if (index == this.newProject.milestones.length - 1) {
                  this.newProject = { isLoading: false, milestones: [{}] };
                  this.$emit("closeDialog");
                }
              });
          });
        });
    },
    addMilestone() {
      this.newProject.milestones.push({});
    }
  }
};
</script>
