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
          <span class="title font-weight-bold mt-2">Milestones</span>
          <v-layout wrap v-for="(milestone, index) in newProject.milestones" :key="index">
            <v-flex xs12 sm8>
              <v-text-field
                label="Milestone"
                v-model="milestone.title"
                placeholder="What's the goal of this milestone?"
              />
            </v-flex>
            <v-flex xs12 sm2>
              <!-- TODO: Convert to WEI for smart contracts -->
              <v-text-field
                label="Ξ Goal"
                type="number"
                step=".01"
                min="0"
                v-model="milestone.amountGoal"
                placeholder="Cost"
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
// import web3 from "../../contracts/web3";

export default {
  data() {
    return {
      account: null,
      newProject: { isLoading: false, milestones: [{}] }
    };
  },
  mounted() {
    // web3.eth.getAccounts().then(accounts => {
    //   [this.account] = accounts;
    // });
  },
  methods: {
    createProject() {
      // this.newProject.isLoading = true;
      // crowdfundInstance.methods
      //   .startProject(
      //     this.newProject.title,
      //     this.newProject.description,
      //     this.newProject.milestones
      //   )
      //   .send({
      //     from: this.account
      //   })
      //   .then(res => {
      //     const projectInfo = res.events.ProjectStarted.returnValues;
      //     projectInfo.isLoading = false;
      //     projectInfo.currentAmount = 0;
      //     projectInfo.currentState = 0;
      //     projectInfo.contract = crowdfundProject(projectInfo.contractAddress);
      //     this.startProjectDialog = false;
      //     this.newProject = { isLoading: false };
      //   });
    },
    addMilestone() {
      this.newProject.milestones.push({});
    }
  }
};
</script>
