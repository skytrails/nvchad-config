<!-- 演示案例二编辑弹窗 -->
<template>
  <el-dialog
    :title="isUpdate?'修改演示案例二':'添加演示案例二'"
    :visible="visible"
    width="460px"
    :destroy-on-close="true"
    :lock-scroll="false"
    @update:visible="updateVisible">
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="82px">
        <el-form-item label="头像：">
          <uploadImage :limit="1" :updDir="updDir" v-model="form.avatar"></uploadImage>
        </el-form-item>
        <el-form-item
          label="案例名称:"
          prop="name">
          <el-input
            :maxlength="20"
            v-model="form.name"
            placeholder="请输入案例名称"
            clearable/>
        </el-form-item>
        <el-form-item label="类型:" prop="type">
          <el-select
            clearable
            class="ele-block"
            v-model="form.type"
            placeholder="请选择类型">
            <el-option label="京东" :value="1"/>
            <el-option label="淘宝" :value="2"/>
            <el-option label="拼多多" :value="3"/>
            <el-option label="唯品会" :value="4"/>
          </el-select>
        </el-form-item>
        <el-form-item label="状态:" prop="status">
          <el-radio-group
            v-model="form.status">
            <el-radio :label="1">正常</el-radio>
            <el-radio :label="2">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="显示顺序:" prop="sort">
          <el-input-number
            :min="0"
            v-model="form.sort"
            placeholder="请输入显示顺序"
            controls-position="right"
            class="ele-fluid ele-text-left"/>
        </el-form-item>
        <el-form-item label="备注:">
          <el-input
            :rows="3"
            clearable
            type="textarea"
            :maxlength="200"
            v-model="form.note"
            placeholder="请输入备注"/>
        </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button @click="updateVisible(false)">取消</el-button>
      <el-button
        type="primary"
        @click="save"
        :loading="loading">保存
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import uploadImage from '@/components/uploadImage'

export default {
  name: 'Example2Edit',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object
  },
  components: {uploadImage},
  data() {
    return {
      // 表单数据
      form: Object.assign({}, this.data),
      // 表单验证规则
      rules: {
        avatar: [
          {required: true, message: '请输入头像', trigger: 'blur'}
        ],
        name: [
          {required: true, message: '请输入案例名称', trigger: 'blur'}
        ],
        type: [
          {required: true, message: '请选择类型', trigger: 'blur'}
        ],
        status: [
          {required: true, message: '请选择状态', trigger: 'blur'}
        ],
        sort: [
          {required: true, message: '请输入显示顺序', trigger: 'blur'}
        ],
        note: [
          {required: true, message: '请输入备注', trigger: 'blur'}
        ],
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'example2',
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
  methods: {
    /* 保存编辑 */
    save() {
      this.$refs['form'].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http[this.isUpdate ? 'put' : 'post'](this.isUpdate ? '/example2/edit' : '/example2/add', this.form).then(res => {
            this.loading = false;
            if (res.data.code === 0) {
              this.$message.success(res.data.msg);
              if (!this.isUpdate) {
                this.form = {};
              }
              this.updateVisible(false);
              this.$emit('done');
            } else {
              this.$message.error(res.data.msg);
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
    }
  }
}
</script>

<style scoped>
</style>
