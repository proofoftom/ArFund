<template>
  <!-- eslint-disable -->
  <v-container>
    <v-layout row justify-center>
      <p class="headline my-12">Utilizing Ethereum and Arweave for Unstoppable Crowdfunding</p>
    </v-layout>
    <v-layout row justify-center>
      <v-dialog v-model="showDialog" max-width="600px">
        <template v-slot:activator="{ on }">
          <v-btn slot="activator" color="primary" dark v-on="on">Start a Project</v-btn>
        </template>
        <CreateProjectForm @closeDialog="showDialog = false" />
      </v-dialog>
    </v-layout>
  </v-container>
</template>

<script>
import CreateProjectForm from "./CreateProjectForm";

export default {
  data() {
    return {
      showDialog: false
    };
  },
  components: {
    CreateProjectForm
  }
};
</script>
