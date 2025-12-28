<!-- 会员编辑弹窗 -->
<template>
  <el-dialog
    width="750px"
    :visible="visible"
    :lock-scroll="false"
    :destroy-on-close="true"
    custom-class="ele-dialog-form"
    :title="isUpdate?'修改APP版本':'添加APP版本'"
    @update:visible="updateVisible">
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="115px">
      <el-form-item label="版本号：" prop="versionCode">
        <el-input
          clearable
          :maxlength="20"
          v-model="form.versionCode"
          placeholder="请输入版本号，例如1.0.0"/>
      </el-form-item>
      <el-form-item label="版本名称：" prop="versionName">
        <el-input
          clearable
          :maxlength="20"
          v-model="form.versionName"
          placeholder="请输入版本名称，例如v1.0.0"/>
      </el-form-item>
      <el-form-item label="发布日期:" prop="releaseDate">
        <el-date-picker
          type="date"
          class="ele-fluid"
          v-model="form.releaseDate"
          value-format="yyyy-MM-dd"
          placeholder="请选择发布日期"/>
      </el-form-item>
      <el-form-item label="渠道名称:" prop="channelName">
        <el-select
          clearable
          class="ele-block"
          v-model="form.channelName"
          placeholder="请选择渠道名称">
          <el-option label="Google Play" value="GooglePlay"/>
          <el-option label="App Store" value="AppStore"/>
        </el-select>
      </el-form-item>
      <el-form-item label="下载链接：" prop="downloadUrl">
        <el-input
          clearable
          :maxlength="255"
          v-model="form.downloadUrl"
          placeholder="请输入版下载链接，http开头"/>
      </el-form-item>
      <el-form-item label="文件大小：" prop="fileSize">
        <el-input
          clearable
          :maxlength="20"
          v-model="form.fileSize"
          placeholder="请输入文件大小，kb"/>
      </el-form-item>
      <el-form-item label="更新日志:" prop="updateLog">
        <el-input
          :rows="3"
          clearable
          type="textarea"
          :maxlength="1000"
          v-model="form.updateLog"
          placeholder="请输入更新日志"/>
      </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button
        @click="updateVisible(false)">取消
      </el-button>
      <el-button
        type="primary"
        :loading="loading"
        @click="save">保存
      </el-button>
    </div>
  </el-dialog>
</template>

<script>

export default {
  name: 'CfAppVersionsEdit',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object
  },
  components: {},
  data() {
    return {
      // 表单数据
      form: Object.assign({status: 1}, this.data),
      // 表单验证规则
      rules: {
        versionCode: [
          {required: true, message: '请输入版本号', trigger: 'blur'}
        ],
        versionName: [
          {required: true, message: '请输入版本名称', trigger: 'blur'}
        ],
        downloadUrl: [
          {required: true, message: '请输入下载链接', trigger: 'blur'}
        ],
        releaseDate: [
          {required: true, message: '请选择发布日期', trigger: 'blur'}
        ],
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
      }
    }
  },
  mounted() {
  },
  methods: {
    /* 保存编辑 */
    save() {
      this.$refs['form'].validate((valid) => {
        if (valid) {
          this.loading = true;
          // 城市数据处理
          const form = Object.assign({}, this.form);
          this.$http.post(this.isUpdate ? '/cfAppVersions/edit' : '/cfAppVersions/add', form).then(res => {
            this.loading = false;
            if (res.data.code === 200) {
              this.$message({type: 'success', message: res.data.message});
              if (!this.isUpdate) {
                this.form = {};
              }
              this.updateVisible(false);
              this.$emit('done');
            } else {
              this.$message.error(res.data.message);
            }
          }).catch(e => {
            this.loading = false;
            this.$message.error(e.message);
          });
        } else {
          return false;
        }
      });
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
    },
  }
}
</script>

<style scoped>
</style>
