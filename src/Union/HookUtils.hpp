#include <Union/Signature.h>
#include <ZenGin/zGothicAPI.h>

#define ADDRESS_OF(what) Union::FindSignatureAddress(Union::SIGNATURE_OF(what))

namespace Union
{
    void* FindSignatureAddress(const Signature& sig)
    {
        if (sig.GetAddress() != nullptr)
        {
            return sig.GetAddress();
        }

        auto* file = SignatureFile::GetFromFile(zSwitch("Signatures_G1.tsv", "Signatures_G1A.tsv", "Signatures_G2.tsv", "Signatures_G2A.tsv"));
        auto* signature = file->FindSimilarSignature(const_cast<Signature*>(&sig));
        if (!signature)
        {
            StringANSI::Format("\u001B[33mSignature not found, returning nullptr\t{0}\u001B[0m", sig.ToString(false)).StdPrintLine();
            return nullptr;
        }
        return signature->GetAddress();
    }

    void* FindSignatureAddress(Signature&& sig)
    {
        return FindSignatureAddress(sig);
    }

    void* FindSignatureAddress(Signature* sig)
    {
        return FindSignatureAddress(*sig);
    }
}
