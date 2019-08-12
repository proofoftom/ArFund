<template>
  <div>
    <CreateProject />
    <ProjectList />
  </div>
</template>

<script>
// @ is an alias to /src
import CreateProject from "@/components/CreateProject";
import ProjectList from "@/components/ProjectList";

export default {
  name: "home",
  components: {
    CreateProject,
    ProjectList
  }
};
</script>
